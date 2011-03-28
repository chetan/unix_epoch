
# concept borrowed from Perl's DateTime::Format::Epoch on CPAN
# instead of Rata Die (RD), we use Julian Date (JD), which is
# better understood by Ruby's DateTime library

require 'date'

module UnixEpoch

    module ClassMethods

        # Create a new DateTime object from a given Unix Timestamp
        #
        # @param [Fixnum, Bignum] unix_ts       seconds since unix epoch (1970-01-01 00:00:00 UTC)
        # @param [Fixnum] offset        offset in seconds from UTC time
        # @return [DateTime]            DateTime object representation of the given Unix TS
        def from_unix_ts(unix_ts, offset = 0)

            # step 1) get the delta in days, seconds and nano seconds represented by unix_ts

            delta_days = UnixEpoch._floor(unix_ts / 86_400)
            unix_ts -= delta_days * 86_400

            # unix_ts cannot be negative now, so to_i instead of _floor()
            delta_secs = unix_ts.to_i
            unix_ts -= delta_secs

            delta_nano = unix_ts / 1e9

            # step 2) add these deltas to the jd day and jd sec representation of the unix epoch

            epoch_jd = UnixEpoch.jd_unix_epoch()

            epoch_jd_days = epoch_jd.to_i
            epoch_secs = UnixEpoch.get_jd_secs(epoch_jd) # get left over seconds from our epoch

            jd_days = epoch_jd_days + delta_days

            secs = epoch_secs + delta_secs + offset # add tz offset back in also
            jd_secs = UnixEpoch.secs_to_jd_secs(secs) + Rational(delta_nano.round, 86_400_000_000)

            return DateTime.from_jd(jd_days, jd_secs, offset)
        end

    end

    module InstanceMethods

        # Converts the current Date & Time into a Fixnum or Bignum representing
        # the Unix Timestamp
        #
        # @return [Fixnum, Bignum]      unix timestamp
        def to_unix_ts
            delta_days = self.jd - UnixEpoch.jd_unix_epoch()
            unix_ts = delta_days * 86_400
            h, m, s = self.class.day_fraction_to_time(day_fraction)
            delta_secs = h * 3600 + m * 60 + s
            delta_secs -= UnixEpoch.jd_fr_to_secs(offset) if offset != 0 # remove tz offset to get back to UTC
            unix_ts += delta_secs
        end

        # (see #to_unix_ts)
        def to_i
            self.to_unix_ts
        end

    end


    private

    # Returns a Julian Date representing the Unix Epoch (January 1, 1970 00:00:00 UTC)
    #
     # @return [Fixnum]  Julian Date representing the Unix Epoch
    def self.jd_unix_epoch
        Date.civil(1970, 1, 1).jd
    end

    # Convert the given number of seconds into a JD fraction
    #
    # @return [Rational]    JD fraction representing the time
    def self.secs_to_jd_secs(secs)
      Rational(secs, 86_400)
    end

    # Retrieve the seconds part of the given Julian Date
    #
    # @param [Float]    Julian Date including fractional value (e.g., 2455647.543)
    # @return [Fixnum]  Number of seconds represented by the fractional value
    def self.get_jd_secs(jd)
        jd_fr_to_secs(jd % 1)
    end

    # Convert the given Julian Date fractional value into seconds
    #
    # @param [Float]    Julian Date fractional value (e.g., 0.543)
    # @return [Fixnum]  Number of seconds represented by the fractional value
    def self.jd_fr_to_secs(fr)
        h, m, s = DateTime.day_fraction_to_time(fr)
        (h * 3600 + m * 60 + s)
    end

    def self._floor(x)
        ix = x.to_i
        if ix <= x then
            return ix
        end
        return ix - 1
    end

end

class DateTime

    extend UnixEpoch::ClassMethods
    include UnixEpoch::InstanceMethods

    # Create a new DateTime object from a given JD
    #
    # +sg+ specifies the Day of Calendar Reform.
    def self.from_jd(jd, fr, of = 0, sg=ITALY)
        of = Rational(of, 86_400) if of != 0 and not of.kind_of? Rational
        new!(jd_to_ajd(jd, fr, of), of, sg)
    end
end
