import 'package:flutter/material.dart';

class AddNewCarScreen extends StatefulWidget {
  const AddNewCarScreen({super.key});

  @override
  State<AddNewCarScreen> createState() => _AddNewCarScreenState();
}

class _AddNewCarScreenState extends State<AddNewCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _parkingNumberController =
      TextEditingController();

  final Map<String, List<String>> _carModelsByType = const {
    'SEDAN': [
      'CHEVROLET AVEO SIVA',
      'CHEVROLET BEAT',
      'CHEVROLET SPARK',
      'CHEVROLET OPTRA SIVA',
      'CHEVROLET SAIL HATCHBACK',
      'CHEVROLET AVEO LT',
      'DATSUN GO',
      'DATSUN GO PLUS',
      'FIAT 500',
      'FIAT ABARTH 595',
      'FIAT ABARTH PUNTO',
      'FIAT PALIO D',
    ],
    'SUV': [
      'CHEVROLET CAPTIVA',
      'CHEVROLET TAHOE',
      'CHEVROLET TRAX',
      'FORD EXPEDITION',
      'FORD EXPLORER',
      'HONDA PILOT',
      'HONDA CR-V',
      'HYUNDAI CRETA',
      'HYUNDAI TUCSON',
      'KIA SPORTAGE',
    ],
    'HATCHBACK': [
      'HYUNDAI GRAND I10',
      'HYUNDAI I20',
      'KIA PICANTO',
      'KIA RIO',
      'MAZDA 2',
      'NISSAN MICRA',
      'SUZUKI SWIFT',
      'TOYOTA YARIS',
    ],
  };

  String? _selectedCarType;
  String? _selectedCarModel;

  @override
  void dispose() {
    _carTypeController.dispose();
    _vehicleModelController.dispose();
    _vehicleNumberController.dispose();
    _colorController.dispose();
    _parkingNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _sectionTitle('SELECT YOUR CAR TYPE'),
          const SizedBox(height: 12),
          _buildCarTypeDropdown(),
          const SizedBox(height: 24),

          _sectionTitle('SELECT YOUR CAR'),
          const SizedBox(height: 12),
          _buildCarModelDropdown(),
          const SizedBox(height: 32),

          _buildLabeledField(
            label: 'CAR TYPE *',
            controller: _carTypeController,
            readOnly: true,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Select a car type' : null,
          ),
          const SizedBox(height: 18),

          _buildLabeledField(
            label: 'VEHICLE MODEL *',
            controller: _vehicleModelController,
            readOnly: true,
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Select a car model' : null,
          ),
          const SizedBox(height: 18),

          _buildLabeledField(
            label: 'VEHICLE NUMBER *',
            controller: _vehicleNumberController,
            hintText: 'Enter vehicle number',
            validator: (value) => (value == null || value.isEmpty)
                ? 'Enter vehicle number'
                : null,
          ),
          const SizedBox(height: 18),

          _buildLabeledField(
            label: 'COLOR *',
            controller: _colorController,
            hintText: 'Enter vehicle color',
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter color' : null,
          ),
          const SizedBox(height: 18),

          _buildLabeledField(
            label: 'PARKING NUMBER *',
            controller: _parkingNumberController,
            hintText: 'Enter parking number',
            validator: (value) => (value == null || value.isEmpty)
                ? 'Enter parking number'
                : null,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04CDFE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF04CDFE),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF04CDFE).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 15),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCarTypeDropdown() {
    final items = _carModelsByType.keys.toList();
    return DropdownButtonFormField<String>(
      value: _selectedCarType,
      dropdownColor: const Color(0xFF0B0E1F),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      style: const TextStyle(color: Colors.white),
      decoration: _dropdownDecoration('Select car type'),
      items: items
          .map(
            (type) => DropdownMenuItem<String>(value: type, child: Text(type)),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCarType = value;
          _selectedCarModel = null;
          _carTypeController.text = value ?? '';
          _vehicleModelController.clear();
        });
      },
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Select a car type' : null,
    );
  }

  Widget _buildCarModelDropdown() {
    final models = _selectedCarType != null
        ? _carModelsByType[_selectedCarType] ?? []
        : <String>[];

    return DropdownButtonFormField<String>(
      value: _selectedCarModel,
      dropdownColor: const Color(0xFF0B0E1F),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      style: const TextStyle(color: Colors.white),
      decoration: _dropdownDecoration(
        _selectedCarType == null
            ? 'Select car type first'
            : 'Select your car model',
      ),
      items: models
          .map(
            (model) =>
                DropdownMenuItem<String>(value: model, child: Text(model)),
          )
          .toList(),
      onChanged: _selectedCarType == null
          ? null
          : (value) {
              setState(() {
                _selectedCarModel = value;
                _vehicleModelController.text = value ?? '';
              });
            },
      validator: (value) {
        if (_selectedCarType == null) {
          return 'Select a car type first';
        }
        return (value == null || value.isEmpty) ? 'Select a car model' : null;
      },
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(hintText: hintText ?? ''),
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF0B0E1F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF04CDFE), width: 1.5),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF0B0E1F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF04CDFE), width: 1.5),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Car details saved successfully'),
        backgroundColor: Color(0xFF00D4AA),
      ),
    );
    Navigator.pop(context);
  }
}
