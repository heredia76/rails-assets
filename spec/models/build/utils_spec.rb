require 'spec_helper'

module Build
  describe Utils do
    context '#bower' do
      it 'executes bower command and returns JSON' do
        expect(silence_stream(STDOUT) {
          Utils.bower('/', 'info jquery#2.0.3')
        }).to be_a(Hash)
      end

      it 'raises BowerError on bower error' do
        expect{silence_stream(STDOUT) {
          Utils.bower('/', 'info jquery#0.0.0')
        }}.to raise_error(BowerError)
      end
    end
    
    context '#fix_version_string' do
      specify do
        expect(Utils.fix_version_string('master')).to be_nil
      end

      specify do
        expect(Utils.fix_version_string('latest')).to be_nil
      end

      specify do
        expect(Utils.fix_version_string('2.0.3-foo')).to eq('2.0.3.foo')
      end

      specify do
        expect(Utils.fix_version_string('>=2.0.1')).to eq('>= 2.0.1')
      end

      specify do
        expect(Utils.fix_version_string('>= 2.0.1 < 2.1.0')).to eq('~> 2.0.1')
      end

      specify do
        expect(Utils.fix_version_string('>= 2.0.1-foo < 2.1.0')).to eq('~> 2.0.1.foo')
      end

      specify do
        expect(Utils.fix_version_string('>= 2.1.2 < 3.0.0')).to eq('~> 2.1')
      end

      specify do
        expect(Utils.fix_version_string('~ 2.1.2')).to eq('~> 2.1.2')
      end

      specify do
        expect(Utils.fix_version_string('2.3.x')).to eq('~> 2.3.0')
      end

      specify do
        expect(Utils.fix_version_string('v2.3.x')).to eq('~> 2.3.0')
      end

      specify do
        expect(Utils.fix_version_string('foo/bar2')).to eq(nil)
      end

      specify do
        expect(Utils.fix_version_string(
          'https://github.com/voodootikigod/node-csv/tarball/master')
        ).to eq(nil)
      end

      specify do
        expect(Utils.fix_version_string(
          'https://github.com/voodootikigod/node-csv/tarball/v2.3.1-foo'
        )).to eq('2.3.1.foo')
      end

      specify do
        expect(Utils.fix_version_string('~1.x')).to eq('~> 1.0')
      end

      specify do
        expect(Utils.fix_version_string('~3.4')).to eq('~> 3.4')
      end
    end

    context '#fix_gem_name' do
      it 'does notthing if version is normal' do
        expect(Utils.fix_gem_name('foobar', '0.2.1')).to eq('foobar')
        expect(Utils.fix_gem_name('foobar', nil)).to eq('foobar')
      end

      it 'uses repository name if version is github url' do
        expect(Utils.fix_gem_name(
          'node-csv', 'https://github.com/voodootikigod/node-csv/tarball/v2.3.1-foo'
        )).to eq('voodootikigod--node-csv')
      end

      it 'removes .git postfix from git url' do
        expect(Utils.fix_gem_name(
          'tinymce', 'git://github.com/jozzhart/tinymce.git#4.0.0'
        )).to eq('jozzhart--tinymce')
      end
    end
  end
end
