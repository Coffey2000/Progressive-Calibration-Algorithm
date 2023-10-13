

function [LUT_all] = phase_shifter_all_LUT()

 

Count = 0;

LUT_all = [];

      for c1 = 0:1:3

          for c0 = 0:1:15 

                Count = Count + 1;

                LUT_all = [LUT_all; Count c0 c1];

            end

      end

end
