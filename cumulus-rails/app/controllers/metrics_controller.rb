class MetricsController < ApplicationController
  respond_to :json

  before_filter :find_metric

  def show
  end

  def aggregate
    resolution = params[:resolution]

    from = Time.at(params[:from].to_i)
    to   = Time.at(params[:to  ].to_i)

    dataset = @metric.aggregate(resolution).where(timestamp: from..to)

    respond_with dataset
  end

private

  def find_metric
    @metric = Metric[params[:id]]
  end
end
