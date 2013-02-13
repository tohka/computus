#!/usr/bin/ruby


# A module for calculating the date of the Easter.
module Computus

	# Returns the date of the Easter.
	#
	# This is an alias of {.pascha}, but a default value of
	# +is_julian+ is false.
	#
	# @example
	#   # the Easter of 2013
	#   Computus::easter(2013)
	#   #=> 2013-03-31 12:00:00 UTC
	#
	# @param [Integer] year
	# @param [Boolean] is_julian
	# @return [Time] date of Easter
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.easter(year, is_julian = false)
		raise TypeError unless year.kind_of?(Integer)
		raise TypeError unless is_julian == true || is_julian == false

		date = fullmoon(year, is_julian)
		wday = (wday0300(year, is_julian) + date) % 7

		Time.utc(year, 3, 1, 12) + (date + (7 - wday) - 1) * 86400
	end

	# Returns the date of the Pascha.
	#
	# This is an alias of {.easter}, but a default value of
	# +is_julian+ is true.
	#
	# @example
	#   # the Pascha of 2013 (Julian calendar)
	#   Computus::pascha(2013)
	#   #=> 2013-04-22 12:00:00 UTC
	#
	#   # the Pascha of 2013 (Gregorian calendar)
	#   Computus::pascha(2013) + Computus::gj_diff(2013) * 86400
	#   #=> 2013-05-05 12:00:00 UTC
	#
	# @param [Integer] year
	# @param [Boolean] is_julian
	# @return [Time] date of Pascha
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.pascha(year, is_julian = true)
		raise TypeError unless year.kind_of?(Integer)
		raise TypeError unless is_julian == true || is_julian == false

		easter(year, is_julian)
	end

	# Butcher algorithm for calculating the date of the Gregorian Easter.
	#
	# @param [Integer] year
	# @return [Time] date of Easter
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.butcher(year)
		raise TypeError unless year.kind_of?(Integer)

		a = year % 19
		b = year / 100
		c = year % 100
		d = b / 4
		e = b % 4
		f = (b + 8) / 25
		g = (b - f + 1) / 3
		h = (19 * a + b - d - g + 15) % 30
		i = c / 4
		k = c % 4
		l = (32 + 2 * e + 2 * i - h - k) % 7
		m = (a + 11 * h + 22 * l) / 451
		n = h + l - 7 * m + 114
		Time.utc(year, n / 31, n % 31 + 1, 12)
	end

	# Meeus algorithm for calculating the date of the Julian Easter(Pascha).
	#
	# @param [Integer] year
	# @return [Time] date of Pascha
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.meeus(year)
		raise TypeError unless year.kind_of?(Integer)

		a = year % 4
		b = year % 7
		c = year % 19
		d = (19 * c + 15) % 30
		e = (2 * a + 4 * b - d + 34) % 7
		f = d + e + 114
		Time.utc(year, f / 31, f % 31 + 1, 12)
	end

	# Returns the difference between Gregorian calendar and Julian calendar.
	#
	# @example
	#   # the Pascha of 2013 (Gregorian calendar)
	#   Computus::pascha(2013) + Computus::gj_diff(2013) * 86400
	#   #=> 2013-05-05 12:00:00 UTC
	#
	# @param [Integer] year
	# @return [Integer] days
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.gj_diff(year)
		raise TypeError unless year.kind_of?(Integer)

		y = year / 100
		-2 + 3 * (y / 4) + (y % 4)
	end

	# Returns the Golden Number.
	#
	# @param [Integer] year
	# @return [Integer] Golden Number
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.golden_number(year)
		raise TypeError unless year.kind_of?(Integer)

		(year % 19) + 1
	end

	# Returns the epact.
	#
	# @param [Integer] year
	# @param [Boolean] is_julian
	# @return [Integer] epact
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.epact(year, is_julian = false)
		raise TypeError unless year.kind_of?(Integer)
		raise TypeError unless is_julian == true || is_julian == false

		gn = golden_number(year)

		epact = [8, 19, 0, 11, 22, 3, 14, 25, 6, 17, 28,
				9, 20, 1, 12, 23, 4, 15, 26][gn-1]
		unless is_julian
			y = year / 100
			diff = ((y + 7) % 25) / 3
			diff = -2 + (diff == 8 ? 7 : diff) +
					8 * ((y + 7) / 25) - 3 * (y / 4) - y % 4
			epact = (epact + diff) % 30
		end

		epact
	end

	# Returns the date of the new moon.
	#
	# @param [Integer] year
	# @param [Boolean] is_julian
	# @return [Integer] days from March 0
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.newmoon(year, is_julian = false)
		raise TypeError unless year.kind_of?(Integer)
		raise TypeError unless is_julian == true || is_julian == false

		gn = golden_number(year)
		epact = epact(year, is_julian)
		if epact <= 23
			31 - epact
		elsif epact == 24
			36
		elsif epact == 25
			gn >= 12 ? 35 : 36
		else
			61 - epact
		end
	end

	# Returns the date of the full moon.
	#
	# @param [Integer] year
	# @param [Boolean] is_julian
	# @return [Integer] days from March 0
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.fullmoon(year, is_julian = false)
		raise TypeError unless year.kind_of?(Integer)
		raise TypeError unless is_julian == true || is_julian == false

		newmoon(year, is_julian) + 13
	end

	# Returns the day of the week when March 0.
	#
	# @param [Integer] year
	# @param [Boolean] is_julian
	# @return [Integer] wday
	# @raise [TypeError] when types of given arguments are unexpected.
	def self.wday0300(year, is_julian = false)
		raise TypeError unless year.kind_of?(Integer)
		raise TypeError unless is_julian == true || is_julian == false

		if is_julian
			y = year % 28
			(5 * (y / 4) + (y % 4)) % 7
		else
			y = year % 400
			(2 + 5 * (y / 100) + 5 * ((y % 100) / 4) + (y % 4)) % 7
		end
	end
end

