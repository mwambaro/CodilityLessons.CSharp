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
            int min = 0;

            try
            {
                int N = A.Length;
                for(int p=1; p<N; p++)
                {
                    int sum = 0;
                    for(int j=0; j<N; j++)
                    {                       
                        sum = j >= p ? sum - A[j] : sum + A[j];
                    }
                    sum = sum >= 0 ? sum : -sum;
                    //Console.WriteLine($"P: {p}; S: {sum}");
                    if (p == 1) // initialize ordering algorithm
                    {
                        min = sum;
                    }
                    if(sum < min) // start ordering algorithm
                    {
                        min = sum;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("TapeEquilibrium: " + ex.Message);
            }

            return min;
        }

        public delegate bool XIsReachable(int X, int[] A);
        public static int FrogRiverOne(int X, int[] A)
        {
            int earliestTime = -1;

            try
            {
                XIsReachable IsXReachable = (x, a) =>
                {
                    bool isr = true;

                    try
                    {
                        var supportPositions = Enumerable.Range(1, x);
                        isr = a.Intersect(supportPositions)
                               .OrderBy(p => p)
                               .SequenceEqual(supportPositions) ? true : false;
                    }
                    catch (Exception ex)
                    {
                        System.Console.WriteLine("IsXReachable: " + ex.Message);
                    }

                    return isr;
                };

                if(IsXReachable(X, A))
                { 
                    for(int t=X-1; t<A.Length; t++)
                    {
                        var subA = A.Take(t + 1);
                        if (IsXReachable(X, subA.ToArray()))
                        {
                            earliestTime = t;
                            break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("FrogRiverOne: " + ex.Message);
            }

            return earliestTime;
        }

        public static int[] MaxCounters(int N, int[] A)
        {
            int[] counters = new int[N];

            try
            {
                // Init counters
                counters = counters.Select(i => i = 0).ToArray();
                var countersRange = Enumerable.Range(1, N);
                foreach(var a in A)
                { 
                    if (countersRange.Contains(a))
                    {
                        counters[a-1] += 1; // increment a-th counter
                    }
                    else if(a == N + 1) // max all counters
                    {
                        int max = counters.Max();
                        counters = counters.Select(c => c = max).ToArray();
                    }
                    else
                    {
                        Console.WriteLine("Assumption A[K] is in [1, N+1] broken.");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("MaxCounters: " + ex.Message);
            }

            return counters;
        }

        public static int MissingInteger(int[] A)
        {
            int missing = 1;

            try
            {
                int max = A.Max();
                int min = A.Min();
                //Console.WriteLine($"Max: {max}; Min: {min}");
                // Ranges where to search for
                // .. [1, Min-1] range
                IEnumerable<int> range = default;
                if (min <= 0)
                {
                    if (max <= 0) // One is the smallest positive missing integer
                    {
                        return 1; 
                    }
                    else
                    {
                        range = Enumerable.Range(1, max-1);
                    }
                }
                else
                {
                    range = Enumerable.Range(1, min-1);
                }
                //Console.WriteLine($"Range: {range?.Count()}");
                // search the [1, Min-1] range
                if (range?.Count() > 0)
                {
                    var diff = range.Except(A);
                    if (diff?.Count() > 0)
                    {
                        return diff.Min();
                    }
                }

                // .. [Min+1, Max-1] range
                if(min > 0 && max > 0)
                {
                    if (min == max)
                    {
                        return max + 1;
                    }
                    else
                    {
                        range = Enumerable.Range(min + 1, max - 1);
                        // search the [Min+1, Max-1] range
                        if (range?.Count() > 0)
                        {
                            var diff = range.Except(A);
                            if (diff?.Count() > 0)
                            {
                                return diff.Min();
                            }
                        }
                    }
                }
                else
                {
                    Console.WriteLine("According to the sequence of operations it is impossible that max is <= 0.");
                }

                // .. [Max, Max+1] range
                missing = max + 1;
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("MissingInteger: " + ex.Message);
            }

            return missing;
        }

        public static int PermCheck(int[] A)
        {
            int isPerm = 0;

            try
            {
                int N = A.Length;
                var model = Enumerable.Range(1, N).OrderBy(e => e);
                if(A.OrderBy(e => e).SequenceEqual(model))
                {
                    isPerm = 1;
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("PermCheck: " + ex.Message);
            }

            return isPerm;
        }
    }
}
