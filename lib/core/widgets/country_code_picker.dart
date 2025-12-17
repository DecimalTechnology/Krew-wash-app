import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

class CountryCodePicker extends StatefulWidget {
  final Function(CountryCode) onChanged;
  final CountryCode? initialSelection;

  const CountryCodePicker({
    super.key,
    required this.onChanged,
    this.initialSelection,
  });

  @override
  State<CountryCodePicker> createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<CountryCodePicker> {
  CountryCode? _selectedCountry;
  final List<CountryCode> _countries = [
    const CountryCode(
      name: 'United Arab Emirates',
      code: 'AE',
      dialCode: '+971',
      flag: '🇦🇪',
    ),
    const CountryCode(
      name: 'Saudi Arabia',
      code: 'SA',
      dialCode: '+966',
      flag: '🇸🇦',
    ),
    const CountryCode(
      name: 'Kuwait',
      code: 'KW',
      dialCode: '+965',
      flag: '🇰🇼',
    ),
    const CountryCode(
      name: 'Qatar',
      code: 'QA',
      dialCode: '+974',
      flag: '🇶🇦',
    ),
    const CountryCode(
      name: 'Bahrain',
      code: 'BH',
      dialCode: '+973',
      flag: '🇧🇭',
    ),
    const CountryCode(name: 'Oman', code: 'OM', dialCode: '+968', flag: '🇴🇲'),
    const CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    const CountryCode(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
    ),
    const CountryCode(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flag: '🇬🇧',
    ),
    const CountryCode(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    const CountryCode(
      name: 'Australia',
      code: 'AU',
      dialCode: '+61',
      flag: '🇦🇺',
    ),
    const CountryCode(
      name: 'Pakistan',
      code: 'PK',
      dialCode: '+92',
      flag: '🇵🇰',
    ),
    const CountryCode(
      name: 'Bangladesh',
      code: 'BD',
      dialCode: '+880',
      flag: '🇧🇩',
    ),
    const CountryCode(
      name: 'Philippines',
      code: 'PH',
      dialCode: '+63',
      flag: '🇵🇭',
    ),
    const CountryCode(name: 'Egypt', code: 'EG', dialCode: '+20', flag: '🇪🇬'),
    const CountryCode(
      name: 'Jordan',
      code: 'JO',
      dialCode: '+962',
      flag: '🇯🇴',
    ),
    const CountryCode(
      name: 'Lebanon',
      code: 'LB',
      dialCode: '+961',
      flag: '🇱🇧',
    ),
    const CountryCode(
      name: 'Turkey',
      code: 'TR',
      dialCode: '+90',
      flag: '🇹🇷',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialSelection ?? _countries.first;
  }

  void _showCountryCodePicker(bool isIOS) {
    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          height: 300,
          color: const Color(0xFF0B0E1F),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white24, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Country',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Color(0xFF00D4AA)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCountry = country;
                        });
                        widget.onChanged(country);
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Text(
                            country.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              country.name,
                              style: TextStyle(
                                color: _selectedCountry?.code == country.code
                                    ? const Color(0xFF00D4AA)
                                    : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            country.dialCode,
                            style: TextStyle(
                              color: _selectedCountry?.code == country.code
                                  ? const Color(0xFF00D4AA)
                                  : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          if (_selectedCountry?.code == country.code) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              CupertinoIcons.checkmark,
                              color: Color(0xFF00D4AA),
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF0B0E1F),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          height: 400,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white24, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Country',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Color(0xFF00D4AA)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          color: _selectedCountry?.code == country.code
                              ? const Color(0xFF00D4AA)
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            country.dialCode,
                            style: TextStyle(
                              color: _selectedCountry?.code == country.code
                                  ? const Color(0xFF00D4AA)
                                  : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          if (_selectedCountry?.code == country.code) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check,
                              color: Color(0xFF00D4AA),
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                        });
                        widget.onChanged(country);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return GestureDetector(
      onTap: () => _showCountryCodePicker(isIOS),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isIOS ? 16 : 12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedCountry?.flag ?? '🇦🇪',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 6),
            Text(
              _selectedCountry?.dialCode ?? '+971',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isIOS ? CupertinoIcons.chevron_down : Icons.arrow_drop_down,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
