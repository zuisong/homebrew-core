class Pinocchio < Formula
  desc "Efficient and fast C++ library implementing Rigid Body Dynamics algorithms"
  homepage "https://stack-of-tasks.github.io/pinocchio"
  url "https://github.com/stack-of-tasks/pinocchio/releases/download/v4.0.0/pinocchio-4.0.0.tar.gz"
  sha256 "0cfa23e2874eb9978dd7d952f3d8df855adb14e166b1a31860ac5c28c6348fb4"
  license "BSD-2-Clause"
  head "https://github.com/stack-of-tasks/pinocchio.git", branch: "devel"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256                               arm64_tahoe:   "86760207b0a7782de6ca11d04726d572890eb3cba376d18bdd5d7c443daf3556"
    sha256                               arm64_sequoia: "678658704bb233f5551f42558bcc2fe6059393b40778fe82a835ce22f0e552de"
    sha256                               arm64_sonoma:  "5b909398a93744936f8eb31da544d85956036ef736d167d751fed2fbe3eb28dc"
    sha256 cellar: :any,                 sonoma:        "88cccbcb3217a83fb2460ae41b38afd9d99edef7e3e311e25d84bfc56d48b765"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "63d9387d9e37e929257b1e50f02ae50607d4ffa600082a6783fc1cdec975dc11"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3b2477eb36d42baeef8bfcd2456bfc1b02ac161297a880ad5a301785e2993732"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pkgconf" => :build

  depends_on "boost"
  depends_on "boost-python3"
  depends_on "coal"
  depends_on "console_bridge"
  depends_on "eigen"
  depends_on "eigenpy"
  depends_on "python@3.14"
  depends_on "urdfdom"

  on_macos do
    depends_on "octomap"
  end

  def python3
    "python3.14"
  end

  def install
    if build.head?
      system "git", "submodule", "update", "--init"
      system "git", "pull", "--unshallow", "--tags"
    end

    args = %W[
      -DPYTHON_EXECUTABLE=#{which(python3)}
      -DBUILD_UNIT_TESTS=OFF
      -DBUILD_WITH_COLLISION_SUPPORT=ON
    ]
    args << "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath,#{rpath}" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system python3, "-c", <<~PYTHON
      import pinocchio
      model = pinocchio.Model()
      data = model.createData()
      assert model.nv == 0 and model.nq == 0
    PYTHON
  end
end
