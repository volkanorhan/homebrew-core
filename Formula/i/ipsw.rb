class Ipsw < Formula
  desc "Research tool for iOS & macOS devices"
  homepage "https://blacktop.github.io/ipsw"
  url "https://github.com/blacktop/ipsw/archive/refs/tags/v3.1.561.tar.gz"
  sha256 "90de70df43a0432b58f964416f44273f384e1ab92cb9a5b86e50171634ea6534"
  license "MIT"
  head "https://github.com/blacktop/ipsw.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "244748e43ae91d75f94968f28200dd816ad44baa4d99511505b729c3a2069ea1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "66735c710fc5582c1ad2fedade7a29703cb468fa746464bd8bfa04620d07ca9e"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "110cfb2d6383a41c8b1098a4f1d204e7277851558ed0bb1a34bdfc2752bc20c6"
    sha256 cellar: :any_skip_relocation, sonoma:        "de3055e62df46a61c1b172bc458b49561838964d1a8e8eb6748a763d65d91dcb"
    sha256 cellar: :any_skip_relocation, ventura:       "1cc6a5b7178bb954044738242bad8a681dbefce1bc391e663c75cf3ddfa1a47c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8c39f43c6c2f0987025892fb43e51ca9668c93bc9841f7841b61281e55f85229"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=#{version}
      -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppBuildCommit=Homebrew
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/ipsw"
    generate_completions_from_executable(bin/"ipsw", "completion")
  end

  test do
    assert_match version.to_s, shell_output(bin/"ipsw version")

    assert_match "MacFamily20,1", shell_output(bin/"ipsw device-list")
  end
end
