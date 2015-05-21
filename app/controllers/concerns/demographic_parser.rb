module DemographicParser
  extend ActiveSupport::Concern

  ALLOWED_MARKERS = ['political_leaning', 'language']

  def extract_demographic params
    demo = {}
    puts params
    ALLOWED_MARKERS.each do |m|
      if params.has_key? m
        # Extract demographic and check that it has valid options
        demo[m]=params[m]
      end
    end
    puts demo
    demo

  end

end
