# frozen_string_literal: true

class BooksController < ApplicationController
  include HTTParty
  base_uri 'https://openlibrary.org'

  def index; end

  def show
    query = params[:query]
    books = search_books(query)

    if books
      render partial: 'books/results', locals: { data: books, query: query }
    else
      render_error(query)
    end
  end

  private

  def search_books(query)
    response = self.class.get('/search.json', query: { q: query })

    response.success? ? response.parsed_response['docs'].first(10) : nil
  rescue StandardError => e
    Rails.logger.error("OpenLibrary error: #{e.message}")
    nil
  end

  def render_error(query)
    render turbo_stream: turbo_stream.replace(
      'books_result',
      "<div class='text-red-600'>Could not fetch books for “#{query}”.</div>"
    )
  end
end
