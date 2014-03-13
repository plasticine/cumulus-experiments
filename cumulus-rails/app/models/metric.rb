# A metric represents a measurement of many facts over time.
class Metric < Sequel::Model
  FACT_COLUMNS = [:timestamp, :count].freeze
  AGGREGATIONS = [:sum, :avg, :min, :max].freeze

  # A metric belongs to an account.
  many_to_one :account

  # A metric has many facts.
  one_to_many :facts, read_only: true, reciprocal: nil, dataset: proc { db[fact_table_name] }

  # Returns the fact table name (qualified by the schema). For example,
  # "account_123__metric_234".
  def fact_table_name
    :"account_#{account_id}__metric_#{id}"
  end

  def grains
    (values[:grains] || []).map(&:to_sym)
  end

  def properties
    (values[:properties] || []).map(&:to_sym)
  end

  # Returns a dataset for the metric which represents an aggregation of facts
  # for a given time resolution.
  def aggregate(resolution)
    # Look up the date/time dimensions for the resolution.
    date_time_dimensions = date_time_dimensions_for_resolution(resolution)

    # Build the timestamp from the date/time dimensions.
    timestamp = Sequel::SQL::NumericExpression.new(:+, *date_time_dimensions).cast(:timestamp).as(:timestamp)

    # Build a window function to sum the counts.
    count_window_function = Sequel::SQL::Function.new(:sum, :count).over(partition: date_time_dimensions).as(:count)

    # Build the aggregation window functions.
    aggregation_window_functions = properties.map do |property|
      AGGREGATIONS.map do |aggregation|
        column = :"#{aggregation}_#{property}"
        Sequel::SQL::Function.new(aggregation, column).over(partition: date_time_dimensions).as(column)
      end
    end.flatten

    facts_dataset
      .join(:dimension_dates, date: Sequel.cast(:timestamp, :date))
      .join(:dimension_times, time: Sequel.cast(:timestamp, :time))
      .distinct(*date_time_dimensions)
      .select(timestamp, count_window_function, *aggregation_window_functions)
  end

  def property_columns
    properties.map do |property|
      AGGREGATIONS.map do |aggregation|
        :"#{aggregation}_#{property}"
      end
    end.flatten
  end

  def grain_columns
    grains
  end

protected

  def validate
    super
    validates_presence [:account, :type]
  end

  def before_validation
    self.grains     = grains.uniq
    self.properties = properties.uniq
    super
  end

  def after_create
    super
    create_fact_table
  end

  def after_save
    super
    add_grain_columns
    add_property_columns
    drop_unused_columns
  end

  def before_destroy
    drop_fact_table
    super
  end

  # Returns the date/time dimension column(s) with which to group the facts for
  # a given time resolution.
  def date_time_dimensions_for_resolution(resolution)
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
    else raise "invalid resolution '#{resolution}'"
    end
  end

  # Returns a SQL function applied to the value column for a given function name.
  def calculate_function(function)
    raise "invalid function '#{function}'" unless [:sum, :avg, :min, :max, :count].include?(function.to_sym)
    Sequel::SQL::Function.new(function.to_sym, :value)
  end

  def create_fact_table
    db.create_table fact_table_name do
      timestamp :timestamp, size: 0, null: false
      Integer :count, null: false
    end

    db.execute "CREATE INDEX metric_#{id}_date_index ON #{self.class.dataset.quote_schema_table(fact_table_name)} ((timestamp::date))"
    db.execute "CREATE INDEX metric_#{id}_time_index ON #{self.class.dataset.quote_schema_table(fact_table_name)} ((timestamp::time))"
  end

  def drop_fact_table
    db.drop_table fact_table_name
  end

  def add_grain_columns
    add_grain_columns = grain_columns - (grain_columns & facts_dataset.columns) - FACT_COLUMNS

    db.alter_table fact_table_name do
      add_grain_columns.each do |column|
        add_column column, String
        add_index column
      end
    end
  end

  def add_property_columns
    add_property_columns = property_columns - (property_columns & facts_dataset.columns) - FACT_COLUMNS

    db.alter_table fact_table_name do
      add_property_columns.each do |column|
        add_column column, Float
      end
    end
  end

  def drop_unused_columns
    drop_columns = facts_dataset.columns - grain_columns - property_columns - FACT_COLUMNS

    db.alter_table fact_table_name do
      drop_columns.each do |column|
        drop_column column
      end
    end
  end
end
