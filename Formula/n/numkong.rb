class Numkong < Formula
  desc "SIMD-accelerated operations and kernels for numeric types"
  homepage "https://github.com/ashvardanian/NumKong"
  url "https://github.com/ashvardanian/NumKong/archive/refs/tags/v7.6.0.tar.gz"
  sha256 "490c7de894ad8f0c2f40f06c65a6cdccdb7b64d082d5406d5267d9ab96da7033"
  license "Apache-2.0"

  depends_on "cmake" => :build

  def install
    ENV.runtime_cpu_detection
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      #include <stdint.h>
      #include <inttypes.h>
      #include <numkong/numkong.h>

      int main() {
          int dimensions = 4;
          uint8_t vector_a[] = {1, 2, 3, 4};
          uint8_t vector_b[] = {2, 2, 2, 2};
          uint32_t result = 0;
          nk_dot_u8(vector_a, vector_b, dimensions, &result);
          printf("%" PRIu8, result);
          return 0;
      }
    C
    system ENV.cc, "./test.c", "-I#{include}", "-L#{lib}", "-lnumkong", "-o", "test"
    assert_equal "20", shell_output("./test")
  end
end
