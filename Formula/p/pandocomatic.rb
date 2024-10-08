class Pandocomatic < Formula
  desc "Automate the use of pandoc"
  homepage "https://heerdebeer.org/Software/markdown/pandocomatic/"
  url "https://github.com/htdebeer/pandocomatic/archive/refs/tags/1.1.3.tar.gz"
  sha256 "5bbc608b6f12690c18818f1d4934d82d11a5df0a3a0864b60ace48482982af6a"
  license "GPL-3.0-or-later"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, all: "4b5303fc2c4da3be01510620566f4e9efde3adf52315956df75c884a1c920a0f"
  end

  depends_on "pandoc"
  depends_on "ruby"

  resource "optimist" do
    url "https://rubygems.org/gems/optimist-3.0.1.gem"
    sha256 "336b753676d6117cad9301fac7e91dab4228f747d4e7179891ad3a163c64e2ed"
  end

  resource "paru" do
    url "https://rubygems.org/gems/paru-1.3.gem"
    sha256 "e031d4f008bd2aa298c5ca7a9d2270b4b2d2c3a5ceb3c39ca5a2afcba020ad17"
  end

  def install
    ENV["GEM_HOME"] = libexec
    resources.each do |r|
      system "gem", "install", r.cached_download, "--ignore-dependencies",
             "--no-document", "--install-dir", libexec
    end
    system "gem", "build", "#{name}.gemspec"
    system "gem", "install", "#{name}-#{version}.gem"
    bin.install libexec/"bin/#{name}"
    bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
  end

  test do
    (testpath/"test.md").write <<~EOS
      # Homebrew

      A package manager for humans. Cats should take a look at Tigerbrew.
    EOS
    expected_html = <<~EOS
      <h1 id="homebrew">Homebrew</h1>
      <p>A package manager for humans. Cats should take a look at
      Tigerbrew.</p>
    EOS
    system bin/"pandocomatic", "-i", "test.md", "-o", "test.html"
    assert_equal expected_html, (testpath/"test.html").read
  end
end
