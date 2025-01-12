class Nuxeo < Formula
  desc "Enterprise Content Management"
  homepage "https://nuxeo.github.io/"
  url "https://packages.nuxeo.com/repository/maven-public/org/nuxeo/ecm/distribution/nuxeo-server-tomcat/11.4.42/nuxeo-server-tomcat-11.4.42.zip"
  sha256 "38b6e7495223ff9e54857bd78fab832f1462201c713fba70a2a87d6a5d8cdd24"
  license "Apache-2.0"

  livecheck do
    url "https://doc.nuxeo.com/nxdoc/master/installing-the-nuxeo-platform-on-mac-os/"
    regex(%r{href=.*?/nuxeo-server-tomcat[._-]v?(\d+(?:\.\d+)+)\.zip}i)
  end

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia:  "be539f51e82cac0c62396dbaa6cef1b5aed902b7eeb6db157ff4ed27d5867cae"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "91529a50c5884a8acfe586aeed26e210a16c586394561cb1dd877cdb9e753284"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "9934a6e927552abb69fded251e937080ea9982e343870b8ce0eebde144ac5b52"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "9934a6e927552abb69fded251e937080ea9982e343870b8ce0eebde144ac5b52"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "9934a6e927552abb69fded251e937080ea9982e343870b8ce0eebde144ac5b52"
    sha256 cellar: :any_skip_relocation, sonoma:         "abda12e73ac873abc6eaaf7cc8d8ba5a68d979ee9104821623fad2ffaf5a8707"
    sha256 cellar: :any_skip_relocation, ventura:        "0510b9e5e54d325058dd57c1f6246f551b32fd34f7282480c4c03a85cba10ce7"
    sha256 cellar: :any_skip_relocation, monterey:       "0510b9e5e54d325058dd57c1f6246f551b32fd34f7282480c4c03a85cba10ce7"
    sha256 cellar: :any_skip_relocation, big_sur:        "0510b9e5e54d325058dd57c1f6246f551b32fd34f7282480c4c03a85cba10ce7"
    sha256 cellar: :any_skip_relocation, catalina:       "0510b9e5e54d325058dd57c1f6246f551b32fd34f7282480c4c03a85cba10ce7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "9934a6e927552abb69fded251e937080ea9982e343870b8ce0eebde144ac5b52"
  end

  depends_on "exiftool"
  depends_on "ghostscript"
  depends_on "imagemagick"
  depends_on "libwpd"
  depends_on "openjdk"
  depends_on "poppler"

  def install
    libexec.install Dir["#{buildpath}/*"]

    env = Language::Java.overridable_java_home_env
    env["NUXEO_HOME"] = libexec.to_s
    env["NUXEO_CONF"] = "#{etc}/nuxeo.conf"

    chmod 0755, libexec/"bin/nuxeoctl"
    (bin/"nuxeoctl").write_env_script libexec/"bin/nuxeoctl", env

    inreplace "#{libexec}/bin/nuxeo.conf" do |s|
      s.gsub!(/#nuxeo\.log\.dir.*/, "nuxeo.log.dir=#{var}/log/nuxeo")
      s.gsub!(/#nuxeo\.data\.dir.*/, "nuxeo.data.dir=#{var}/lib/nuxeo/data")
      s.gsub!(/#nuxeo\.pid\.dir.*/, "nuxeo.pid.dir=#{var}/run/nuxeo")
    end
    etc.install "#{libexec}/bin/nuxeo.conf"
  end

  def post_install
    (var/"log/nuxeo").mkpath
    (var/"lib/nuxeo/data").mkpath
    (var/"run/nuxeo").mkpath
    (var/"cache/nuxeo/packages").mkpath

    libexec.install_symlink var/"cache/nuxeo/packages"
  end

  def caveats
    <<~EOS
      You need to edit #{etc}/nuxeo.conf file to configure manually the server.
      Also, in case of upgrade, run 'nuxeoctl mp-upgrade' to ensure all
      downloaded addons are up to date.
    EOS
  end

  test do
    ENV["JAVA_HOME"] = Formula["openjdk"].opt_prefix

    # Copy configuration file to test path, due to some automatic writes on it.
    cp "#{etc}/nuxeo.conf", "#{testpath}/nuxeo.conf"
    inreplace "#{testpath}/nuxeo.conf" do |s|
      s.gsub! var.to_s, testpath
      s.gsub!(/#nuxeo\.tmp\.dir.*/, "nuxeo.tmp.dir=#{testpath}/tmp")
    end

    ENV["NUXEO_CONF"] = "#{testpath}/nuxeo.conf"

    assert_match %r{#{testpath}/nuxeo\.conf}, shell_output("#{libexec}/bin/nuxeoctl config --get nuxeo.conf")
    assert_match libexec.to_s, shell_output("#{libexec}/bin/nuxeoctl config --get nuxeo.home")
  end
end
