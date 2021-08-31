using System;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;

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

        public static int CountDiv(int A, int B, int K)
        {
            int counter = 0;

            try
            {
                // Ensure first int is divisible by K then apply
                // Nbre of intervals == Nbre of int divisible by K (+1 depends on the divisibility of B by K)
                int firstInt = A;
                if(A < K && A > 0)
                {
                    firstInt = K;
                }
                else
                {
                    int mod = A % K;
                    firstInt = mod == 0 ? A : A + K - mod;
                }
                // Ensure first int is <= B
                int KLongIntervals = 0;
                if (firstInt <= B)
                {
                    KLongIntervals = (int)Math.Ceiling((double)(B - firstInt) / K);
                    if(KLongIntervals == 0) // Either B and firstInt are 0 or they are equal
                    {
                        return 1;
                    }
                }
                if(KLongIntervals > 0)
                {
                    counter = B % K == 0 ? KLongIntervals + 1 : KLongIntervals;
                }
                else
                {
                    counter = KLongIntervals;
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("CountDiv: " + ex.Message);
            }

            return counter;
        }

        public static int[] GenomicRangeQuery(string S, int[] P, int[] Q)
        {
            int[] genomic = null;

            try
            {
                Dictionary<string, int> impacts = new Dictionary<string, int>
                {
                    {"A", 1 }, {"C", 2}, {"G", 3}, {"T", 4}
                };
                genomic = P.Select((p, idx) => {
                    int minImpact = 0;
                    string genome = S.Substring(p, Q[idx]-p+1);
                    //Console.WriteLine("Genome: " + genome);
                    
                    minImpact = genome.Select(g =>
                    {
                        int impact = 0;
                        if(g == 'A')
                        {
                            impact = impacts["A"];
                        }
                        else if(g == 'C')
                        {
                            impact = impacts["C"];
                        }
                        else if (g == 'G')
                        {
                            impact = impacts["G"];
                        }
                        else if (g == 'T')
                        {
                            impact = impacts["T"];
                        }

                        return impact;
                    }).Min();
                    
                    return minImpact;
                }).ToArray();
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("GenomicRangeQuery: " + ex.Message);
            }

            return genomic;
        }

        public static int MinAvgTwoSlice(int[] A)
        {
            int minAvgPos = 0;

            try
            {
                int N = A.Length;
                decimal minAvgDb = 0;
                for(int p=0; p<N-1; p++)
                {
                    decimal prevSum = 0;
                    for(int q=p+1; q<N; q++)
                    {
                        decimal nextOperand = 0;
                        if (prevSum == 0) // We are at q=p+1; i.e., we have two elts to compute average for
                        {
                            nextOperand = A[p] + A[q];
                        }
                        else // We have one elt to add to the previous sum
                        {
                            nextOperand = A[q];
                        }
                        int nElts = q - p + 1;
                        decimal sum = prevSum + nextOperand;
                        prevSum = sum;
                        decimal avg = sum / nElts;
                        //Console.WriteLine($"({p}, {q}) => {avg}");
                        if (p == 0)// Init
                        {
                            minAvgDb = avg;
                            minAvgPos = p;
                        }
                        if (minAvgDb > avg) // finding min
                        {
                            minAvgDb = avg;
                            minAvgPos = p;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("MinAvgTwoSlice: " + ex.Message);
            }

            return minAvgPos;
        }

        /// <summary>
        /// Challenge Jan 2021 at Codility (https://app.codility.com/programmers/challenges/)
        /// </summary>
        /// <param name="A"> Array of integer number of black squares per column </param>
        /// <returns>Side length of biggest black square </returns>
        public static int BiggestBlackSquareLength(int[] A)
        {
            int biggest = 0;

            try
            {
                int N = A.Length;
                for(int i=0; i<N; i++)
                {
                    int expectedL = A[i];
                    for (int k = expectedL; k > 0; k--)
                    {
                        int counter = 0;
                        int bound = i + k;
                        if (bound <= N)
                        {
                            for (int j = i + 1; j < bound; j++)
                            {
                                if (A[j] >= k) // May lead to a square
                                {
                                    counter += 1;
                                }
                                else
                                {
                                    break;
                                }
                            }
                        }
                        Console.WriteLine($"ExpectedL: {k} [{counter}]");
                        if (counter == (k - 1)) // We've got a square
                        {
                            if (biggest < k) // Find max
                            {
                                biggest = k;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("BiggestBlackSquareLength: " + ex.Message);
            }

            return biggest;
        }

        public static int PassingCars(int[] A)
        {
            int nPassingCars = 0;

            try
            {
                int N = A.Length;
                for (int P=0; P<N-1; P++)
                {
                    if (A[P] != 0)
                    {
                        continue;
                    }
                    for(int Q=P+1; Q<N; Q++)
                    {
                        if(A[Q] == 1)
                        {
                            nPassingCars += 1;
                        }
                    }
                }

                const int nMax = 1000000000;
                if(nPassingCars > nMax)
                {
                    nPassingCars = -1;
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("PassingCars: " + ex.Message);
            }

            return nPassingCars;
        }

        public delegate IDictionary<int, int> IsPossiblyNested(string s);
        public delegate string ReplaceCharacters(string s, int[] indices, char c);
        public static int Brackets(string S)
        {
            int properlyNested = 0;

            try
            {
                if(S == null)
                {
                    Console.WriteLine("Unhandled 'case': S is null.");
                    return properlyNested;
                }
                if( S == "")
                {
                    properlyNested = 1;
                }
                else
                {
                    ReplaceCharacters ReplaceOpeningAndClosing = (s, indices, c) =>
                    {
                        string rs = s;

                        try
                        {
                            rs = new string(
                                rs.Select((cc, kk) =>
                                {
                                    char newChar = cc;
                                    foreach (int ijk in indices)
                                    {
                                        if (kk == ijk)
                                        {
                                            newChar = c;
                                        }
                                    }

                                    return newChar;
                                }
                            ).ToArray());
                        }
                        catch (Exception ex)
                        {
                            System.Console.WriteLine("Brackets:ReplaceOpeningAndClosing " + ex.Message);
                        }

                        return rs;
                    };

                    /// returns (opening index, closing index) dictionary
                    /// If no partner is available -1 is as value or a negative key
                    IsPossiblyNested PossiblyNested = (ss) => 
                    {
                        IDictionary<int, int> partners = new Dictionary<int, int>();

                        try
                        {
                            string s = (string)ss.Clone(); // new string(ss);
                            
                            Stack<int> openings = new Stack<int>();
                            IList<int> closings = new List<int>();
                            var matches = Regex.Matches(s, @"[\{\[\(\}\]\)]");
                            foreach (Match m in matches)
                            {
                                int index = m.Index;
                                switch (s[index])
                                {
                                    case '{': openings.Push(index); break;
                                    case '[': openings.Push(index); break;
                                    case '(': openings.Push(index); break;
                                    case '}': closings.Add(index); break;
                                    case ']': closings.Add(index); break;
                                    case ')': closings.Add(index); break;
                                }
                            }

                            //foreach (var o in openings) Console.WriteLine($"{ss[o]} => {ss}");
                            //foreach (var c in closings) Console.WriteLine($"{ss[c]} => {ss}");

                            int count = openings.Count;
                            for(int i=0; i<count; i++) 
                            {
                                if(openings.Count == 0)
                                {
                                    break;
                                }
                                int idx = openings.Pop();
                                string opening = ss[idx].ToString();
                                foreach (int j in closings)
                                {
                                    string closing = null;
                                    switch (ss[idx])
                                    {
                                        case '{': closing = "}"; break;
                                        case '[': closing = "]"; break;
                                        case '(': closing = ")"; break;
                                    }
                                    bool theyMatch = ss[j].ToString() == closing;
                                    if (j > idx && theyMatch)
                                    {
                                        string u = s.Substring(idx + 1, j-idx-1);
                                        //Console.WriteLine($"{idx} #{u}# {j} => $${s}$$");
                                        if (!string.IsNullOrEmpty(u))
                                        {
                                            var m = Regex.Match(u, Regex.Escape(opening));
                                            var mm = Regex.Match(u, Regex.Escape(closing));
                                            if (!m.Success && !mm.Success) 
                                            {
                                                if (1 == Brackets(u))
                                                {
                                                    partners.Add(idx, j);
                                                    int[] indices = new int[] { idx, j };
                                                    s = ReplaceOpeningAndClosing(s, indices, ' ');
                                                    //Console.WriteLine("String: " + s);
                                                    closings.Remove(j); // It makes sense due to the next break
                                                    break;
                                                }
                                            }
                                        }
                                        else
                                        {
                                            partners.Add(idx, j);
                                            int[] indices = new int[] { idx, j };
                                            s = ReplaceOpeningAndClosing(s, indices, ' ');
                                            //Console.WriteLine("String: " + s);
                                            closings.Remove(j); // It makes sense due to the next break
                                            break;
                                        }
                                    }
                                    else
                                    {
                                        //Console.WriteLine($"{idx} -- {j} => $${s}$$");
                                    }
                                }
                                if (!partners.ContainsKey(idx))
                                {
                                    partners.Add(idx, -1);
                                    int[] indices = new int[] { idx };
                                    s = ReplaceOpeningAndClosing(s, indices, ' ');
                                    //Console.WriteLine("String: " + s);
                                }
                            }
                            // Check closings
                            int cki = -1;
                            foreach(int j in closings)
                            {
                                if (!partners.Values.Contains(j))
                                {
                                    partners.Add(cki, j);
                                    cki -= 1;
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            System.Console.WriteLine("Brackets:PossiblyNested " + ex.Message);
                        }

                        return partners;
                    };

                    var partnersDico = PossiblyNested(S);
                    properlyNested = 1;
                    foreach (var pk in partnersDico)
                    {
                        //Console.WriteLine($"Opening => Closing: {pk.Key} => {pk.Value} $${S}$$");
                        if (pk.Value == -1 || pk.Key < 0)
                        {
                            properlyNested = 0;
                            break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("Brackets: " + ex.Message);
            }

            return properlyNested;
        }

        /// <summary>
        /// HankerRank basic problem solving test.
        /// </summary>
        /// <param name="customers"></param>
        /// <returns></returns>
        public static List<string> MostActive(List<string> customers)
        {
            List<string> mActive = new List<string>();

            try
            {
                int N = customers.Count;
                decimal threshold = 5;
                var groups = customers.GroupBy(trade => trade);
                foreach(var g in groups)
                {
                    decimal activity = (g.Count() * 100) / N;
                    if(activity >= threshold)
                    {
                        mActive.Add(g.Key);
                    }
                }

                mActive = mActive.OrderBy(s => s).ToList();
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("MostActive: " + ex.Message);
            }

            return mActive;
        }

        /// <summary>
        /// HankerRank basic problem solving test.
        /// </summary>
        /// <param name="dictionary"></param>
        /// <param name="query"></param>
        /// <returns></returns>
        public static List<int> StringAnagram(List<string> dictionary, List<string> query)
        {
            List<int> occurrences = new List<int>();

            try
            {
                foreach(string q in query)
                {
                    int counter = 0;
                    var qChars = q.Select(p => {
                        return (int)p;
                    }).Sum();
                    foreach(string d in dictionary)
                    {
                        if(d.Length != q.Length)
                        {
                            continue;
                        }
                        var dChars = d.Select(pp => {
                            return (int)pp;
                        }).Sum(); ;
                        if (qChars == dChars)
                        {
                            counter += 1;
                        }
                    }

                    occurrences.Add(counter);
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("StringAnagram: " + ex.Message);
            }

            return occurrences;
        }

        public static string SuggestedContact(string[] A, string[] B, string P)
        {
            string suggested = "NO CONTACT";

            try
            {
                var contactNames = B.Select((n, i) => {
                    string name = "";
                    var m = Regex.Match(n, Regex.Escape(P));
                    if (m.Success)
                    {
                        name = A[i];
                    }

                    return name;
                }).Where(n => !string.IsNullOrEmpty(n));
                if(contactNames.Count() > 0)
                {
                    suggested = contactNames.OrderBy(c => c).First();
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("SuggestedContact: " + ex.Message);
            }

            return suggested;
        }

        public static string ReformatPhoneNumber(string S)
        {
            string reformatted = "";

            try
            {
                string triplet = "";
                IList<string> triplets = new List<string>();
                foreach(char c in S)
                {
                    string s = c.ToString();
                    if(Regex.IsMatch(s, @"[0-9]"))
                    {
                        triplet += s;
                        if(triplet.Length == 3)
                        {
                            triplets.Add(triplet);
                            triplet = "";
                        }
                    }
                }
                if (!string.IsNullOrEmpty(triplet))
                {
                    if(triplet.Length < 2)
                    {
                        string last = triplets.Last();
                        triplets.RemoveAt(triplets.Count-1);
                        string beforeLast = last.Substring(0, 2);
                        triplets.Add(beforeLast);
                        last = last.Last().ToString() + triplet;
                        triplets.Add(last);
                    }
                    else
                    {
                        triplets.Add(triplet);
                    }
                }
                for(int j=0; j<triplets.Count; j++)
                {
                    if (j == 0)
                    {
                        reformatted = triplets[j];
                    }
                    else
                    {
                        reformatted += $"-{triplets[j]}";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("ReformatPhoneNumber: " + ex.Message);
            }

            return reformatted;
        }

        public static bool ContainsVertex(int N, int[] A, int[] B)
        {
            bool contains = false;

            try
            {
                int M = A.Length;
                int bM = B.Length;
                for (int i=0; i<M; i++)
                {
                    if(A[i] != 1)
                    {
                        continue;
                    }
                    for (int j = 0; j < bM; j++)
                    {
                        if (A[i] == 1 && B[j] == N)
                        {
                            contains = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("ContainsVertex: " + ex.Message);
            }

            return contains;
        }

        public static int MaxPairs(List<int> skillLevel, int minDiff)
        {
            int max = 0;

            try
            {
                int N = skillLevel.Count;
                for (int i=0; i<N-1; i++)
                {
                    for (int j=i+1; j<N; j++)
                    {                        
                        if(skillLevel[j] == -1)// paired
                        {
                            continue;
                        }
                        int diff = Math.Abs(skillLevel[i] - skillLevel[j]);
                        Console.WriteLine($"({skillLevel[i]}, {skillLevel[j]}) => {diff}");
                        if(diff >= minDiff)
                        {
                            max += 1;
                            skillLevel[i] = -1;
                            skillLevel[j] = -1;
                            break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Console.WriteLine("MaxPairs: " + ex.Message);
            }

            return max;
        }

        static int AbsDistinct (int[] A)
        {
            int n = 0;

            try
            { 
            }
            catch(Exception ex)
            {
                System.Console.WriteLine("MaxPairs: " + ex.Message);
            }

            return n;
        }
    }
}
