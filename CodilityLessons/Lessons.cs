using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;

namespace CodilityLessons
{
    public class Lessons
    {
        public static int BinaryGap(int N)
        {
            int longestBinGap = 0;

            try
            {
                var binaryString = Convert.ToString(N, 2);
                var binLength = binaryString.Length;
                char prev = '2';
                IList<int> binGaps = null;
                for (int i=0; i<binLength; i++)
                {
                    var c = binaryString.ElementAt(i);
                    if (c == '0' && prev == '1' ) // possible binary gap
                    {
                        int oCounter = 1;
                        bool oneFound = false;

                        for (int j = i + 1; j < binLength; j++)
                        {
                            char cc = binaryString.ElementAt(j);
                            if (cc == '1')
                            {
                                oneFound = true;
                                break;
                            }
                            else
                            {
                                oCounter++;
                            }
                        }

                        if (oneFound)
                        {
                            if (null == binGaps)
                            {
                                binGaps = new List<int>();
                            }
                            binGaps.Add(oCounter);
                            prev = '1'; // the closing 1
                            i += oCounter; // go beyond the closing 1;
                        }
                        else // straight out of loop
                        {
                            prev = '0'; // the last 0, not needed, though
                            i += oCounter - 1;
                        }
                    }
                    else
                    {
                        prev = c;
                    }
                }

                if (null != binGaps)
                {
                    longestBinGap = binGaps.Max();
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("BinaryGap: " + ex.Message);
            }

            return longestBinGap;
        }
    }
}
