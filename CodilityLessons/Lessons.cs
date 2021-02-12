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

        public static int FrogJmp (int X, int Y, int D)
        {
            int n = 0;

            try
            {
                int diff = Y - X;
                int mod = diff % D;
                if (mod == 0) 
                {
                    n = diff / D;
                }
                else
                {
                    n = ((diff - mod) / D) + 1;
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("FrogJmp: " + ex.Message);
            }

            return n;
        }

        public static int PermMissingElem(int[] A)
        {
            int missing = 0;

            try
            {
                int N = A.Length;
                var range = Enumerable.Range(1, N+1);
                var missingElts = range.Except(A);
                int count = missingElts.Count();
                if (count == 1)
                {
                    missing = missingElts.First();
                }
                else if(count > 1)
                {
                    Console.WriteLine("Assumption violated. More than one element are missing.");
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("PermMissingElem: " + ex.Message);
            }

            return missing;
        }

        public static int TapeEquilibrium(int[] A)
        {
            int min = 1;

            try
            {
                int N = A.Length;
                var diffs = new List<int>();
                for(int p=1; p<N; p++)
                {
                    int sum1 = 0;
                    for(int j=0; j<p; j++)
                    {
                        sum1 += A[j];
                    }
                    int sum2 = 0;
                    for(int j=p; j<N; j++)
                    {
                        sum2 += A[j];
                    }
                    int sumP = Math.Abs(sum1 - sum2);
                    Console.WriteLine($"P: {p}; S: {sumP}");
                    diffs.Add(sumP);
                }
                min = diffs.Min();
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("TapeEquilibrium: " + ex.Message);
            }

            return min;
        }
    }
}
