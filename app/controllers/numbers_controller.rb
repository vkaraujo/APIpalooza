# frozen_string_literal: true

class NumbersController < ApplicationController
  def index; end

  def create
    value = params[:value]
    type = params[:type]

    fact = Numbers::FactFetcher.new(value: value, type: type).call

    if fact
      render partial: 'numbers/result', locals: { fact: fact }
    else
      render_error(value, type)
    end
  end

  def surprise
    value = rand(1..1000)
    type = %w[trivia math year].sample

    fact = Numbers::FactFetcher.new(value: value, type: type).call

    if fact
      warning = "🎲 Random <strong>#{type}</strong> fact about <strong>#{value}</strong>"
      render partial: "numbers/result", locals: { fact: fact, warning: warning }
    else
      render_error(value, type)
    end
  end

  private

  def render_error(value, type)
    render turbo_stream: turbo_stream.replace(
      'numbers_result',
      "<div class='text-red-600'>Could not fetch a #{type} fact for “#{value}”.</div>"
    )
  end
end
