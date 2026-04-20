class Io < Formula
  desc "Small prototype-based programming language"
  homepage "http://iolanguage.com/"
  url "https://github.com/IoLanguage/io/archive/refs/tags/2026.04.20-native-final.tar.gz"
  version "2026.04.20-native-final"
  sha256 "08184259464e536f0a30d6588579b7e99ef260bf375d362be77c458810b41d4a"
  license "BSD-3-Clause"
  head "https://github.com/IoLanguage/io.git", branch: "master"

  bottle do
    rebuild 1
    sha256 arm64_tahoe:   "f52b3f34e2163977455f08819a17df42ebec1148781c3df76411e3743e251d5c"
    sha256 arm64_sequoia: "9cd4d01893fe007c243216871642b659664f5273c0bfa3e6ed52b253e2aa80e7"
    sha256 arm64_sonoma:  "ee036449cf0d3a7752967588f5acf9ad8057821346fa836f372b04a46a88f385"
    sha256 sonoma:        "9ceacf2ba834c91d5101adb7061bfd7c1ae702d9fbbbd9d8f78b5e82d049fd7e"
    sha256 ventura:       "914d9b485bd7ceaec9bc8e43c9ffff86560ced0074ea2ae73312c45fafc0e01e"
    sha256 monterey:      "2bbd166e8e51dd46f71818b6d2acad483af7cd19c2f8f114e5e713a64740d438"
    sha256 arm64_linux:   "7fb2cd769bab17e5a6e13563e09fb02bbd1da5e25d4fe541335b97f9f22fbc04"
    sha256 x86_64_linux:  "28f27659192940b8773ab23b0d237befa1ebb90ca6b771f82852422631f6549e"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  # No tags, so pull the latest commit source tarball
  resource "parson" do
    url "https://github.com/kgabis/parson/archive/ba29f4eda9ea7703a9f6a9cf2b0532a2605723c3.tar.gz"
    sha256 "d311cd3d051965485bff1c89a3980df7ad0ee3f9c0f33c18964d8c1cc32ef2cf"
  end

  def install
    (buildpath/"deps/parson").install resource("parson")

    ENV.O0 if OS.mac? && Hardware::CPU.intel?

    args = %W[
      -DCMAKE_DISABLE_FIND_PACKAGE_ODE=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_Theora=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.io").write <<~IO
      "it works!" println
    IO

    assert_equal "it works!\n", shell_output("#{bin}/io test.io")
  end
end
