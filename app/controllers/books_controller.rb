# frozen_string_literal: true

class BooksController < ApplicationController
  def index; end

  def create
    query = params[:query]
    books = Books::Fetcher.new(query).call

    if books
      render partial: 'books/results', locals: { data: books, query: query }
    else
      render_error(query)
    end
  end

  private

  def render_error(query)
    render turbo_stream: turbo_stream.replace(
      'books_result',
      "<div class='text-red-600'>Could not fetch books for “#{query}”.</div>"
    )
  end
end
