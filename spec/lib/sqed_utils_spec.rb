require 'sqed_utils'

describe SqedUtils do

  context '.corrected_frequency' do

    specify '[1,2,3]' do
      expect(SqedUtils.corrected_frequency([1,2,3])).to eq([1,2,3] )
    end

    specify '[1,2,3], max_width: 100' do
      expect(SqedUtils.corrected_frequency([1,2,3], max_width: 100)).to eq([1,2,3] )
    end

    specify '[90,100,1000], max_width: 2000' do
      expect(SqedUtils.corrected_frequency([90,100,1000], max_width: 2000)).to eq([90, 100, 105] )
    end

    specify '[90,100,1000], max_width: 2000)' do
      expect(SqedUtils.corrected_frequency([90,100,1000], max_width: 2000)).to eq([90, 100, 105] )
    end

    specify '[90,1000,1010], max_width: 2000)' do
      expect(SqedUtils.corrected_frequency([90,1000,1010], max_width: 2000)).to eq([995, 1000, 1010] )
    end

    specify '[10, 12, 20], max_width: 2000' do
      expect(SqedUtils.corrected_frequency([10, 12, 20], max_width: 2000)).to eq([10, 12, 20] )
    end

   specify '[10, 12, 20], max_width: 100)' do
      expect(SqedUtils.corrected_frequency([10, 12, 20], max_width: 100)).to eq([10, 12, 13] )
    end

   specify '[10, 12, 20], max_width: 100, width_factor: 5)' do
     expect(SqedUtils.corrected_frequency([1, 3, 10], max_width: 100, width_factor: 5)).to eq([0, 3, 4] )
   end


  end

end
