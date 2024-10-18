class BalenaCli < Formula
  desc "Command-line tool for interacting with the balenaCloud and balena API"
  homepage "https://www.balena.io/docs/reference/cli/"
  url "https://registry.npmjs.org/balena-cli/-/balena-cli-19.6.0.tgz"
  sha256 "397e816d3626a8f5f81c0a71f9265de95d7604ef28e88fe3daca53764227be7b"
  license "Apache-2.0"

  livecheck do
    url "https://registry.npmjs.org/balena-cli/latest"
    regex(/["']version["']:\s*?["']([^"']+)["']/i)
  end

  bottle do
    sha256                               arm64_sequoia: "ecb3cda9dacdc59fa57922c4bb890fd18894ad5a3b3689a5a333af33a9eade0a"
    sha256                               arm64_sonoma:  "99c6baa5c3d73d698c21a8b524638d8468c4bd91ff20149176057ee158b217d3"
    sha256                               arm64_ventura: "f967cd74f60cdedcc30377763a47f8caa1ebe55be3eced86e0a70bf54d6c735d"
    sha256                               sonoma:        "80d94c49f57b6db073cadb03a29acdbe4245ccc2b1a62ea6e549e63f3e72f4bc"
    sha256                               ventura:       "4162e63d4d295aaaa988ee7c40a801e1e3fc0d49e9a3814ad6e9d8ea691b19a0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "036ceed8bcb1f7db27f315ff6920c95d18b68151c4a4e0e6548b8b8b3dc2e676"
  end

  # need node@20, and also align with upstream, https://github.com/balena-io/balena-cli/blob/master/.github/actions/publish/action.yml#L21
  depends_on "node@20"

  on_linux do
    depends_on "libusb"
    depends_on "systemd" # for libudev
    depends_on "xz" # for liblzma
  end

  def install
    ENV.deparallelize

    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Remove incompatible pre-built binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/balena-cli/node_modules"
    node_modules.glob("{ffi-napi,ref-napi}/prebuilds/*")
                .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }

    rm_r(node_modules/"lzma-native/build")
    rm_r(node_modules/"usb") if OS.linux?

    # Replace universal binaries with native slices
    deuniversalize_machos
  end

  test do
    assert_match "Logging in to balena-cloud.com",
      shell_output("#{bin}/balena login --credentials --email johndoe@gmail.com --password secret 2>/dev/null", 1)
  end
end
