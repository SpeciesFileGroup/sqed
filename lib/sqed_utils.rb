# require 'byebug'

# Functions that don't belong in Sqed proper
#
module SqedUtils


  # @return [Array]
  #    like `[0,1,2]`
  #
  # @param frequency_stats [Array]
  #   like [1,2,3]
  #
  # @param width_factor [Float]
  #    
  #  
  # @param max_width [Integer]
  #   required, the width of the image in question
  #
  # See tests. This code does a rough job of smoothing out boundaries that seem to 
  # be biased on one side or the other.  Definitely could be refined to use a more
  # weighted approach. 
  #
  def self.corrected_frequency(frequency_stats, width_factor: 3.0, max_width: nil)

    return frequency_stats if max_width.nil?

    v0 = frequency_stats[0]
    m = frequency_stats[1]
    v2 = frequency_stats[2]

    width_pct = (v2.to_f - v0.to_f) / max_width.to_f

    return frequency_stats if (width_pct * 100) <= 2.0

    a = (m - v0).abs
    b = (v2 - m).abs

    largest = (a > b ? a : b)

    l = (m - b / 2) 
    l = 0 if l < 0

    r = (m + a / 2)
    r = max_width if r > max_width

    c = a * width_factor
    d = b * width_factor

    [
      c > largest ? l : v0,
      m,
      d > largest ? r : v2
    ]

  end

end
