class Metric < Sequel::Model
  many_to_one :account
  one_to_many :facts, :dataset => proc { db[fact_table_name] }, :read_only => true, :reciprocal => nil

  def fact_table_name; :"account_#{account_id}__metric_#{id}"; end

  def validate
    super
    validates_presence [:account, :type]
  end

  def before_validation
    self.grains = grains.map(&:to_s).uniq
    super
  end

  def after_create
    super
    create_fact_table
  end

  def after_save
    super
    synchronize_fact_table
  end

  def before_destroy
    drop_fact_table
    super
  end

  def aggregate(resolution, function)
    partition = calculate_partition(resolution)
    function  = Sequel::SQL::Function.new(function, :value)
    window    = Sequel::SQL::Window.new(:partition => partition)

    timestamp = Sequel::SQL::NumericExpression.new(:+, *partition).cast(:timestamp).as(:timestamp)
    window_function = Sequel::SQL::WindowFunction.new(function, window).as(:value)

    facts_dataset. \
    join(:dimension_dates, :date => :timestamp.cast(:date)). \
    join(:dimension_times, :time => :timestamp.cast(:time)). \
    distinct(*partition). \
    select(timestamp, window_function)
  end

private

  def calculate_partition(resolution)
    case resolution.to_sym
    when :year         then :nearest_year
    when :month        then :nearest_month
    when :week         then :nearest_week
    when :day          then :date
    when :hour         then [:date, :nearest_hour]
    when :half_hour    then [:date, :nearest_half_hour]
    when :quarter_hour then [:date, :nearest_quarter_hour]
    when :sixth_hour   then [:date, :nearest_sixth_hour]
    when :twelfth_hour then [:date, :nearest_twelfth_hour]
    when :minute       then [:date, :nearest_minute]
    when :second       then [:date, :time]
    else raise "unknown resolution '#{resolution}'"
    end
  end

  def create_fact_table
    db.create_table fact_table_name do
      timestamp :timestamp, :size => 0, :null => false
      Float :value
    end

    db.execute "CREATE INDEX metric_#{id}_date_index ON #{self.class.dataset.quote_schema_table(fact_table_name)} ((timestamp::date))"
    db.execute "CREATE INDEX metric_#{id}_time_index ON #{self.class.dataset.quote_schema_table(fact_table_name)} ((timestamp::time))"
  end

  def drop_fact_table
    db.drop_table fact_table_name
  end

  FACT_COLUMNS = [:timestamp, :value].freeze

  def synchronize_fact_table
    symbolized_grains = grains.map(&:to_sym)
    add_columns = symbolized_grains - (symbolized_grains & facts_dataset.columns) - FACT_COLUMNS
    drop_columns = facts_dataset.columns - symbolized_grains - FACT_COLUMNS

    db.alter_table fact_table_name do
      add_columns.each do |column|
        add_column column, String
        add_index column
      end

      drop_columns.each do |column|
        drop_column column
      end
    end
  end
end
