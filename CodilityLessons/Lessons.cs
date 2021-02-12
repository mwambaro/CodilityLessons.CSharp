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

        public static int[] CyclicRotation(int[] A, int K)
        {
            int[] rotated = null;

            try 
            {
                if(A == null || A?.Length == 0) 
                {
                    return A;
                }
                
                int lastIdx = A.Length - 1;
                var aList = A.ToList();
                for (int i = 0; i < K; i++)
                {
                    int lastElt = aList[lastIdx];
                    aList[lastIdx] = 0; // Gone
                    // aList = aList.Prepend(lastElt).ToList(); did not work for Mono 4.5
                    // at Codility.com, so we are doing it manually
                    for(int j=aList.Count()-1; j>0; j--) // Shifting
                    {
                        aList[j] = aList[j - 1];
                    }
                    aList[0] = lastElt;
                    // End Prepend logic
                }
                rotated = aList.ToArray();
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("CyclicRotation: " + ex.Message);
            }

            return rotated;
        }

        public static int OddOccurrencesInArray(int[] A)
        {
            int unpaired = -1;
            try
            {
                var groups = A.GroupBy(k => k);
                int counter = 0;
                foreach(var g in groups)
                {
                    int length = g.Count();
                    if(length == 1)
                    {
                        unpaired = g.Key;
                        counter += 1;
                    }
                    else
                    {
                        if(length%2 != 0) // Last is unpaired
                        {
                            unpaired = g.Key;
                            counter += 1;
                        }
                    }
                }

                if(counter == 0)
                {
                    System.Console.WriteLine("Assumption violated. No Occurrence of unpaired number.");
                }
                else if(counter > 1)
                {
                    System.Console.WriteLine("Assumption violated. More than one occurrence of unpaired numbers");
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("OddOccurrencesInArray: " + ex.Message);
            }

            return unpaired;
        }
    }
}
