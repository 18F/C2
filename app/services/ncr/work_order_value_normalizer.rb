module Ncr
  class WorkOrderValueNormalizer
    def initialize(work_order)
      @work_order = work_order
    end

    def run
      normalize_cl_number
      normalize_function_code
      normalize_soc_code
    end

    private

    attr_accessor :work_order

    def normalize_cl_number
      if work_order.cl_number.present?
        work_order.cl_number = work_order.cl_number.upcase
        prepend_value(work_order.cl_number, "CL")

      else
        work_order.cl_number = nil
      end
    end

    def normalize_function_code
      if work_order.function_code.present?
        work_order.function_code = work_order.function_code.upcase
        prepend_value(work_order.function_code, "PG")
      else
        work_order.function_code = nil
      end
    end

    def normalize_soc_code
      if work_order.soc_code.present?
        work_order.soc_code = work_order.soc_code.upcase
      else
        work_order.soc_code = nil
      end
    end

    def prepend_value(value, string_start_value)
      unless value.start_with?(string_start_value)
        value.prepend(string_start_value)
      end
    end
  end
end
