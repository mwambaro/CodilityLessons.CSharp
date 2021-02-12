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
    }
}