class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-38.125.0.tgz"
  sha256 "b3f41b666f30b821074959bd4f504f34a91cf37ab5147fc7d57f9190b5cf4840"
  license "AGPL-3.0-only"

  # There are thousands of renovate releases on npm and the page the `Npm`
  # strategy checks is several MB in size and can time out before the request
  # resolves. This checks the first page of tags on GitHub (to minimize data
  # transfer).
  livecheck do
    url "https://github.com/renovatebot/renovate/tags"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cec9074944204f5dd5f488d32d1e9afe3dfd53b6974824c0850f6e19ddf0a291"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "43981bf07ae605748fe40ceb043645ad662a623a5e2fa967bdfacfff6c4cdc6b"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "14c6022d061765471617f6177df725040399287fd3bbd042f3a12781beb393d9"
    sha256 cellar: :any_skip_relocation, sonoma:        "f67191595dcbad734ecc88d0406043811ffc45ae3bcff002218ee1c6465bdffd"
    sha256 cellar: :any_skip_relocation, ventura:       "1afd281ef4cc861a9dce6181806f334d0fad46dfec57b572fb4fd2bdb27f5b3c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "887d454a763d4d1a74f7dd442878c2d329de48c86cfc85e3d72f61d32f220956"
  end

  depends_on "node@20"

  uses_from_macos "git", since: :monterey

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"renovate", "--platform=local", "--enabled=false"
  end
end
