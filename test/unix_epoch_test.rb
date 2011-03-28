
require 'rubygems'
require 'test/unit'
require 'unix_epoch'
require 'timezone_local'

class UnixEpoch_Test < Test::Unit::TestCase

    def setup
        @f = "%Y-%m-%d %H:%M:%S"
    end

    def test_from_unix_ts
        i = 1301103992
        assert DateTime.from_unix_ts(i).strftime(@f) == Time.at(i).utc.strftime(@f)
    end

    def test_from_unix_ts_large_date
        # date > 2038
        i = 2240611200
        assert DateTime.from_unix_ts(i).strftime(@f) == Time.at(i).utc.strftime(@f)
    end

    def test_from_unix_ts_localtime
        i = 1301103992
        assert DateTime.from_unix_ts(i, Time.new.utc_offset).strftime(@f) == Time.at(i).strftime(@f)
    end

    def test_to_unix_ts
        i = 1301103992
        d = DateTime.from_unix_ts(i)
        t = Time.at(i)
        assert d.strftime(@f) == t.utc.strftime(@f)
        assert t.to_i == i
        assert d.to_unix_ts == i
    end

    def test_to_unix_ts_localtime
        i = 1301103992
        d = DateTime.from_unix_ts(i, Time.new.utc_offset)
        t = Time.at(i)
        assert d.strftime(@f) == t.strftime(@f)
        assert t.to_i == i
        assert d.to_unix_ts == i
    end

    def test_from_unix_ts_with_tzinfo
        tz = TZInfo::Timezone.get_local_timezone
        i = 1301103992
        assert DateTime.from_unix_ts(i, tz).strftime(@f) == Time.at(i).strftime(@f)
    end
end
