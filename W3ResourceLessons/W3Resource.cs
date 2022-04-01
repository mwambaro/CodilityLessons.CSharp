using System;
using System.Linq;
using System.Collections.Generic;
using System.Text;

namespace W3ResourceLessons
{
    /// <summary>
    ///     Exercises from https://www.w3resource.com/csharp-exercises/
    /// </summary>
    public class W3Resource
    { 
        public static string[] Basic8MultiplicationTable(int number)
        {
            string[] table = new string[12]; 

            for(int i=0; i<table.Length; i++)
            {
                table[i] = $"{i} * {number} = {i*number}";
            }

            return table;
        }

        /// <summary>
        ///     Copies an array into another array.
        ///     Exercises 4 at https://www.w3resource.com/csharp-exercises/array/index.php
        /// </summary>
        public static int[] ArrayCopyContent(int[] array)
        {
            int[] ary = new int[array.Length];
            array.CopyTo(ary, 0);

            return ary;
        }

        /// <summary>
        ///     Counts duplicates and uniques in a array.
        ///     Exercises 5 & 6 at https://www.w3resource.com/csharp-exercises/array/index.php
        /// </summary>
        /// <param name="array">The filled array </param>
        /// <returns> a int[2]; at 0, number of duplicates; at 1, number of uniques</returns>
        public static int[] ArrayCountDuplicatesAndUnique(int[] array)
        {
            int[] N = new int[2];

            IList<int> uniques = new List<int>();
            IList<int> duplicates = new List<int>();
            for (int i=0; i<array.Length; i++)
            {
                bool duplicated = false;
                for(int j = i+1; j<array.Length; j++)
                {
                    if(array[i] == array[j])
                    {
                        duplicated = true;
                        if(!duplicates.Contains(array[i]))
                        {
                            duplicates.Add(array[i]);
                        }
                    }
                }

                if (!duplicated)
                {
                    if (!duplicates.Contains(array[i]))
                    {
                        uniques.Add(array[i]);
                    }
                }
            }

            N[0] = duplicates.Count();
            N[1] = uniques.Count();

            return N;
        }

        /// <summary>
        ///     Exercise 7 at https://www.w3resource.com/csharp-exercises/array/index.php
        /// </summary>
        public static int[] MergeTwoArraysAndOrderAscending(int[] ary1, int[] ary2)
        {
            int[] merged = new int[ary1.Length+ary2.Length];

            for (int i = 0; i < ary1.Length; i++) merged[i] = ary1[i];
            int j = 0;
            for (int i = ary1.Length; i < merged.Length; i++)
            {
                merged[i] = ary1[j];
                j++;
            }
            var mgd = merged.OrderBy(x => x).ToArray();

            return mgd;
        }

        /// <summary>
        ///     Exercise 8 at https://www.w3resource.com/csharp-exercises/array/index.php
        /// </summary>
        public static IDictionary<int, int> FrequencyOfEachElementInArray(int[] array)
        {

            IDictionary<int, int> freqs = new Dictionary<int, int>();
            for(int i=0; i<array.Length; i++)
            {
                if (freqs.Keys.Contains(array[i])) continue;
                int freq = 1;
                for(int j=i+1; j<array.Length; j++)
                {
                    if(array[i] == array[j])
                    {
                        freq++;
                    }
                }
                freqs.Add(array[i], freq);
            }

            return freqs;
        }
    }
}
