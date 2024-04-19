# frozen_string_literal: true

class TodoList < ApplicationRecord
  has_many :todos, dependent: :destroy, inverse_of: :todo_list

  belongs_to :user, required: true, inverse_of: :todo_lists

  scope :default, -> { where(default: true) }
  scope :non_default, -> { where(default: false) }

  # TODO: Extract this logic into a query object, refactor into a cleaner and more readable way
  scope :order_by, ->(params) {
    order = params[:order]&.strip&.downcase == 'asc' ? :asc : :desc

    sort_by = params[:sort_by]&.strip&.downcase

    column_name = column_names.excluding('id', 'user_id').include?(sort_by) ? sort_by : 'id'

    order(column_name => order)
  }

  validates :title, presence: true
  validates :default, inclusion: { in: [true, false] }
  validate :default_uniqueness

  # TODO: This is not that bad, but we should think of using a gem like FastJSONApi to generate the JSON
  # we can even get this as json from the database, something to look into.
  def serialize_as_json
    as_json(except: [:user_id])
  end

  private

    def default_uniqueness
      errors.add(:default, 'already exists') if default? && user.todo_lists.default.exists?
    end
end
