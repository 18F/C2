class Ncr::WorkOrderValueNormalizer
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

      unless work_order.cl_number.start_with?('CL')
        work_order.cl_number.prepend('CL')
      end
    else
      work_order.cl_number = nil
    end
  end

  def normalize_function_code
    if work_order.function_code.present?
      work_order.function_code = work_order.function_code.upcase

      unless work_order.function_code.start_with?('PG')
        work_order.function_code.prepend('PG')
      end
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
end
