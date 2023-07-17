# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  # @param page [GearedPagination::Page] The pagination page object.
  # @param columns [Array<Hash>] The array of column definitions.
  # @option columns [Symbol] :header The column header.
  # @option columns [Symbol|Proc] :data The data accessor for the column.
  # @option columns [String] :class_name (optional) The class name for the column.
  # @param pagination_component [Class] The pagination component class (default: component("ui/pagination")).
  def initialize(page:, columns: [], pagination_component: component("ui/pagination"))
    @page = page
    @columns = columns.map { Column.new(**_1) }
    @pagination_component = pagination_component
    @model_class = page.records.model
    @rows = page.records
  end

  def render_cell(tag, cell, **attrs)
    # Allow component instances as cell content
    content_tag(tag, **attrs) do
      if cell.respond_to?(:render_in)
        cell.render_in(self)
      else
        cell
      end
    end
  end

  def render_header_cell(cell)
    cell =
      case cell
      when Symbol
        @model_class.human_attribute_name(cell)
      when Proc
        cell.call
      end

    cell_tag = cell.blank? ? :td : :th

    render_cell(cell_tag, cell, class: <<~CLASSES)
      border-b
      border-gray-100
      py-3
      px-4
      text-[#4f4f4f]
      text-left
      text-3.5
      font-[600]
      line-[120%]
    CLASSES
  end

  def render_data_cell(cell, data)
    cell =
      case cell
      when Symbol
        data.public_send(cell)
      when Proc
        cell.call(data)
      end

    render_cell(:td, cell, class: "py-2 px-4")
  end

  def render_table_footer
    if @pagination_component
      tag.tfoot do
        tag.tr do
          tag.td(colspan: @columns.size, class: "py-4") do
            tag.div(class: "flex justify-center") do
              render_pagination_component
            end
          end
        end
      end
    end
  end

  def render_pagination_component
    @pagination_component.new(page: @page).render_in(self)
  end

  Column = Struct.new(:header, :data, :class_name, keyword_init: true)
  private_constant :Column
end