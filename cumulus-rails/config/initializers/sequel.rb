Sequel.default_timezone = :utc

Sequel::Model.plugin :timestamps, update_on_create: true

module Sequel
  class Dataset
    def literal(v)
      case v
      when String
        return v if v.is_a?(LiteralString)
        v.is_a?(SQL::Blob) ? literal_blob(v) : literal_string(v)
      when Symbol
        literal_symbol(v)
      when Integer
        literal_integer(v)
      when Hash
        literal_hash(v)
      when SQL::Expression
        literal_expression(v)
      when Float
        literal_float(v)
      when BigDecimal
        literal_big_decimal(v)
      when NilClass
        literal_nil
      when TrueClass
        literal_true
      when FalseClass
        literal_false
      when Array
        literal_array(v)
      when Time
        literal_time(v)
      when SQLTime # ensure SQLTime comes *after* time
        literal_sqltime(v)
      when DateTime
        literal_datetime(v)
      when Date
        literal_date(v)
      when Dataset
        literal_dataset(v)
      else
        literal_other(v)
      end
    end
  end

  class Model
    def save!
      save raise_on_save_failure: true
    end

    def update!(hash)
      set hash
      save raise_on_save_failure: true
    end
  end
end
