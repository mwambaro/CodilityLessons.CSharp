using NUnit.Framework;
using System.Collections.Generic;

namespace W3ResourceLessons.Tests
{
    public class Tests
    {
        [SetUp]
        public void Setup()
        {
        }

        [Test]
        public void TestBasic8MultiplicationTable()
        {
            int number = 12;
            string[] array = W3ResourceLessons.W3Resource.Basic8MultiplicationTable(number);
            for (int i = 0; i < array.Length; i++)
            {
                Assert.AreEqual($"{i} * {number} = {i * number}", array[i]);
            }
        }

        [Test]
        public void TestArrayCopyContent()
        {
            int[] ary = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
            int[] ary1 = W3Resource.ArrayCopyContent(ary);

            for(int i=0; i<ary.Length; i++)
            {
                Assert.AreEqual(ary[i], ary1[i]);
            }
        }

        [Test]
        public void TestArrayCountDuplicatesAndUnique()
        {
            int[] array = { 1, 2, 20, 2, 56, 1, 100, 320, 20, 400, 600 };
            int[] N = W3Resource.ArrayCountDuplicatesAndUnique(array);
            Assert.AreEqual(N[0], 3);
            Assert.AreEqual(N[1], 5);
        }

        [Test]
        public void TestMergeTwoArraysAndOrderAscending()
        {
            int[] ary1 = { 1, 2, 3 };
            int[] ary2 = { 1, 2, 3};
            int[] merged = W3Resource.MergeTwoArraysAndOrderAscending(ary1, ary2);
            int[] ary3 = { 1, 1, 2, 2, 3, 3 };
            Assert.AreEqual(merged, ary3);
        }

        [Test]
        public void TestFrequencyOfEachElementInArray()
        {
            int[] array = { 1, 2, 20, 2, 56, 1, 100, 320, 20, 400, 600 };
            var freqs = W3Resource.FrequencyOfEachElementInArray(array);
            IDictionary<int, int> expfreqs = new Dictionary<int, int>();
            expfreqs.Add(1, 2);
            expfreqs.Add(2, 2);
            expfreqs.Add(20, 2);
            expfreqs.Add(56, 1);
            expfreqs.Add(100, 1);
            expfreqs.Add(320, 1);
            expfreqs.Add(400, 1);
            expfreqs.Add(600, 1);

            Assert.AreEqual(freqs, expfreqs);
        }
    }
}