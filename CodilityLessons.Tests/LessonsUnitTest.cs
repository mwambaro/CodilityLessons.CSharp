using NUnit.Framework;

namespace CodilityLessons.Tests
{
    public class Tests
    {
        [SetUp]
        public void Setup()
        {
        }

        [Test]
        public void TestBinaryGap()
        {
            int[] Ns = new int[] { 9, 529, 20, 15, 32, 1041, 2500567, 1567845777};

            foreach (int N in Ns)
            {
                var actual = Lessons.BinaryGap(N);
                int expected = 0;

                switch (N)
                {
                    case 9: // Bin: 1001
                        expected = 2;
                        break;
                    case 529: // Bin: 1000010001
                        expected = 4;
                        break;
                    case 20: // Bin: 10100
                        expected = 1;
                        break;
                    case 15: // Bin: 1111
                        expected = 0;
                        break;
                    case 32: // Bin: 100000
                        expected = 0;
                        break;
                    case 1041: // Bin: 10000010001
                        expected = 5;
                        break;
                    case 2500567: // Bin: 1001100010011111010111
                        expected = 3;
                        break;
                    case 1567845777: // Bin: 1011101011100110110110110010001
                        expected = 3;
                        break;
                    default: break;
                }

                Assert.AreEqual(expected, actual);
            }
        }

        [Test]
        public void TestCyclicRotation()
        {
            int[] A = new int[] { 3, 8, 9, 7, 6 };
            int K = 3;
            var expected = new int[] { 9, 7, 6, 3, 8 };
            var actual = Lessons.CyclicRotation(A, K);

            Assert.AreEqual(expected, actual);

            A = new int[] { 0, 0, 0 };
            K = 1;
            expected = new int[] { 0, 0, 0 };
            actual = Lessons.CyclicRotation(A, K);

            Assert.AreEqual(expected, actual);

            A = new int[] { 1, 2, 3, 4 };
            K = 4;
            expected = new int[] { 1, 2, 3, 4 };
            actual = Lessons.CyclicRotation(A, K);

            Assert.AreEqual(expected, actual);
        }

        [Test]
        public void TestOddOccurrencesInArray()
        {
            int[] A = new int[] { 9, 3, 9, 3, 9, 7, 9};
            int expected = 7;
            int actual = Lessons.OddOccurrencesInArray(A);

            Assert.AreEqual(expected, actual);
        }

        [Test]
        public void TestFrogJmp()
        {
            int X = 10, Y = 85, D = 30;
            int expected = 3;
            int actual = Lessons.FrogJmp(X, Y, D);

            Assert.AreEqual(expected, actual);
        }

        [Test]
        public void TestPermMissingElem()
        {
            int[] A = new int[] { 2, 3, 1, 5 };
            int expected = 4;
            int actual = Lessons.PermMissingElem(A);

            Assert.AreEqual(expected, actual);
        }

        [Test]
        public void TestTapeEquilibrium()
        {
            int[] A = new int[] { 3, 1, 2, 4, 3};
            int expected = 1;
            int actual = Lessons.TapeEquilibrium(A);

            Assert.AreEqual(expected, actual);
        }
    }
}