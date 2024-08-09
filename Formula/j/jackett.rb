class Jackett < Formula
  desc "API Support for your favorite torrent trackers"
  homepage "https://github.com/Jackett/Jackett"
  url "https://github.com/Jackett/Jackett/archive/refs/tags/v0.22.425.tar.gz"
  sha256 "cd68891f4ce3fb598739215f123aefbe013c0cb665e23c210347b07985816cf4"
  license "GPL-2.0-only"
  head "https://github.com/Jackett/Jackett.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "fb308874cc7cde89031d8e1a50cebe92c26024c1fb54117a86f578439de6746c"
    sha256 cellar: :any,                 arm64_ventura:  "eac398adf9695a8ba06639358f3fac0f8f751ba0d0af8da831668f27baf3d8cd"
    sha256 cellar: :any,                 arm64_monterey: "b9acf12c42ab9a9be2685405ec204d3bf900bb856e7c572709357883e6770e51"
    sha256 cellar: :any,                 sonoma:         "1e8f5681e116ade29a985f1c67106f6a14c5ffda3166aad330078351f207cbc9"
    sha256 cellar: :any,                 ventura:        "a77476459b74c1783d6041515bd52a1a328fe895ecd0606f56c3b3c06f871bbc"
    sha256 cellar: :any,                 monterey:       "3732ff7812e506ab53ecd06b95229486350264fadf027c0ea2e72511a7381071"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "35104fdd4fd88cad5f11c46bed0ed9d61ee1816e0f1e9f1ed6a3baa00d9aa274"
  end

  depends_on "dotnet"

  def install
    dotnet = Formula["dotnet"]
    os = OS.mac? ? "osx" : OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --runtime #{os}-#{arch}
      --no-self-contained
    ]
    if build.stable?
      args += %W[
        /p:AssemblyVersion=#{version}
        /p:FileVersion=#{version}
        /p:InformationalVersion=#{version}
        /p:Version=#{version}
      ]
    end

    system "dotnet", "publish", "src/Jackett.Server", *args

    (bin/"jackett").write_env_script libexec/"jackett", "--NoUpdates",
      DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}"
  end

  service do
    run opt_bin/"jackett"
    keep_alive true
    working_dir opt_libexec
    log_path var/"log/jackett.log"
    error_log_path var/"log/jackett.log"
  end

  test do
    assert_match(/^Jackett v#{Regexp.escape(version)}$/, shell_output("#{bin}/jackett --version 2>&1; true"))

    port = free_port

    pid = fork do
      exec bin/"jackett", "-d", testpath, "-p", port.to_s
    end

    begin
      sleep 15
      assert_match "<title>Jackett</title>", shell_output("curl -b cookiefile -c cookiefile -L --silent http://localhost:#{port}")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
