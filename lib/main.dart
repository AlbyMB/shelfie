import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:shelfie/database/category_repository.dart';
import 'package:shelfie/database/food_repository.dart';
import 'package:shelfie/database/user_repository.dart';
import 'package:shelfie/models/category_model.dart';
import 'package:shelfie/models/food_model.dart';
import 'package:shelfie/models/user_model.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import "package:http/http.dart" as http;
import "package:http/http.dart";
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginCheck(),
      routes: {
        LoginPage.routeName: (context) => LoginPage(),
        RegisterPage.routeName: (context) => RegisterPage(),
        FoodsPage.routeName: (context) => FoodsPage(),
        ShoppingScreen.routeName: (context) => ShoppingScreen(),
        SettingsPage.routeName: (context) => SettingsPage(),
        HomeScreen.routeName: (context) => HomeScreen(),
        AddFood.routeName: (context) => AddFood(),
        BarcodePage.routeName: (context) => BarcodePage(),

      }
    );
  } 
}

class LoginCheck extends StatefulWidget {
  const LoginCheck({super.key});

  @override
  State<LoginCheck> createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck> {
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    List<User> loggedInUser = await UserRepository().getLoggedInUser();
    if (loggedInUser.isNotEmpty) {
      print("Logged IN");
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      print("NOT LOGGED IN");
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
    Future.delayed(const Duration(seconds: 1), () {
      FlutterNativeSplash.remove();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for email and password fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {

    final prefs = await SharedPreferences.getInstance();

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final user = await UserRepository().getUserByEmail(email);
      if (user.isNotEmpty) {
        
        if (user[0].password == password) {
          user[0].isLoggedIn = 'true';
          await UserRepository().updateUser(user[0], user[0].id!);
        } else {
          // Show a SnackBar or dialog for invalid credentials.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      } else {
        // Show a SnackBar or dialog for invalid credentials.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }

      
      if (user.isNotEmpty && user[0].isLoggedIn == 'true') {
        prefs.setString('userID', user[0].id.toString());
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Constrain the width so that text fields don't span the whole screen.
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 320, // Adjust width as needed to mimic normal app inputs.
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email input field.
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      // Simple email regex validation.
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password input field.
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Login button.
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 10),
                  // Link to registration page.
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RegisterPage.routeName);
                    },
                    child: const Text('Don\'t have an account? Register here'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for registration inputs.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // A simple function to check password complexity.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    // Require a minimum of 8 characters, at least one uppercase, one lowercase and one digit.
    // Adjust the regex pattern based on your complexity requirements.
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$').hasMatch(value)) {
      return 'Password must be at least 8 characters, include upper and lower case letters and a number';
    }
    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      // Check if the password and confirmation match.
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      // Create a new user model (modify to match your User model requirements).
      final user = User(
        email: email,
        password: password,
        createdAt: DateTime.now().toString(),
      );

      // Insert user into your database.
      final result = await UserRepository().insertUser(user);
      if (result != 0) { 
        final newUser = await UserRepository().getUserByEmail(email);

        CategoryRepository().insertCategory(Category(
          name: 'Fridge',
          userId: newUser[0].id!,
        ));

        CategoryRepository().insertCategory(Category(
          name: 'Freezer',
          userId: newUser[0].id!,
        ));

        CategoryRepository().insertCategory(Category(
          name: 'Pantry',
          userId: newUser[0].id!,
        ));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please log in.')),
        );
        Navigator.pushReplacementNamed(context, LoginPage.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed, please try again')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Constrain the width similar to LoginPage.
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email input.
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password input.
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),
                  // Confirm password input.
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Register button.
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 10),
                  // Optionally, a link to go back to login.
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, LoginPage.routeName);
                    },
                    child: const Text('Already have an account? Login here'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FoodsPage(),
    const ShoppingScreen(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Foods',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class FoodsPage extends StatefulWidget {
  const FoodsPage({super.key});

  static const String routeName = '/foods';

  @override
  State<FoodsPage> createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> {

  List<Food> _foods = [];
  List<Category> _categories = [];
  bool _isSearching = false;
  String _searchQuery = '';
  List<Food> _filteredFoods = [];

  
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    final prefs = await SharedPreferences.getInstance();

    String? userID = prefs.getString('userID');

    List<Food> foods = await FoodRepository().getAllFoods(int.parse(userID!));
    List<Category> categories = await CategoryRepository().getAllCategories(int.parse(userID!));

    setState(() {
      _foods = foods; // Update the state to reflect the fetched foods.
      _categories = categories; // Update the state to reflect the fetched categories.
      _filteredFoods = foods;
    });

    
  }
  
  void _onSearchChanged(String query) {
  setState(() {
    _searchQuery = query;
    _filteredFoods = _foods.where((food) {
      return food.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  });
}

  void _deleteFood(Food food) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food'),
        content: Text('Are you sure you want to delete "${food.name}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FoodRepository().deleteFood(food.id!); // Assume this function exists
      _initialize(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${food.name} deleted')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search foods...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('All Foods'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _filteredFoods = _foods;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: _filteredFoods.isEmpty
        ? Center(
            child: Text(
              _searchQuery.isNotEmpty ? 'No matching foods' : 'No foods added yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: _filteredFoods.length,
            itemBuilder: (context, index) {
              final food = _filteredFoods[index];
              final category = _categories.firstWhere(
                (category) => category.id == food.categoryId,
                orElse: () => Category(id: 0, name: 'Unknown', userId: -999),
              );
              return ListTile(
                leading: food.imageUrl != null && food.imageUrl!.isNotEmpty
                    ? Image.network(
                        food.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.fastfood, size: 50, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                title: Text(food.name),
                subtitle: Text(
                  '${category.name} \nQuantity: ${food.quantity ?? 'N/A'} ${food.unit ?? ''}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                onTap: () {
                  debugPrint('Tapped on ${food.name}');
                },
                onLongPress: () {
                  _deleteFood(food);
                },
              );
            },
          ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await Navigator.pushNamed(context, AddFood.routeName);
          _initialize();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  static const String routeName = '/shopping';

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LatLng? _userPos;

  @override
  void initState() {
    super.initState();
    _initLocationAndFetch().catchError((e) {
    print("Error in location fetch: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to get location: ${e.toString()}')),
    );
  });
  }

  Future<void> _initLocationAndFetch() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // You can prompt the user to turn on location settings
    throw Exception('Location services are disabled.');
  }

  // Check and request permission if needed
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Location Permission"),
      content: Text(
          "Location permissions are permanently denied. Please enable them from app settings."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        )
      ],
    ),
  );
  return;
}


  final pos = await Geolocator.getCurrentPosition();
  setState(() {
    _userPos = LatLng(pos.latitude, pos.longitude);
  });
  final places = await _fetchNearbyGroceries(pos);
}


  Future<void> _fetchNearbyGroceries(Position pos) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${pos.latitude},${pos.longitude}'
      '&radius=8000&type=grocery_or_supermarket&key=AIzaSyBiddJ-OpwtctcrjM20CiOIvRG3q2eUUIQ'
    );
    final resp = await http.get(url);
    final data = json.decode(resp.body);
    _addPlaceMarkers(data['results']);
  }

  void _addPlaceMarkers(List<dynamic> places) {
    for (var place in places) {
      final loc = place['geometry']['location'];
      _markers.add(Marker(
        markerId: MarkerId(place['place_id']),
        position: LatLng(loc['lat'], loc['lng']),
        infoWindow: InfoWindow(title: place['name']),
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_userPos == null) return Center(child: CircularProgressIndicator());
    return Scaffold(
  appBar: AppBar(
    title: const Text('Shopping'),
  ),
  body: Stack(
    children: [
      GoogleMap(
        onMapCreated: (c) => _controller = c,
        initialCameraPosition: CameraPosition(target: _userPos!, zoom: 12),
        markers: _markers,
        myLocationEnabled: true,
      ),
      Positioned(
        top: 16,
        left: 16,
        right: 75,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.9 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
          ),
          child: Row(
            children: const [
              Icon(Icons.location_on, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Showing nearby grocery stores',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);

  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Show a confirmation dialog
            final bool? confirmLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Log Out'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // User canceled the logout
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // User confirmed the logout
                    },
                    child: const Text('Log Out'),
                  ),
                ],
              ),
          );

      if (confirmLogout == true) {
        List<User> loggedInUser = await UserRepository().getLoggedInUser();
        if (loggedInUser.isNotEmpty) {
          loggedInUser[0].isLoggedIn = 'false';
          await UserRepository().updateUser(loggedInUser[0], loggedInUser[0].id!);
        }
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('userID');
        Navigator.pushReplacementNamed(context, LoginPage.routeName); 

      }
    },
    child: const Text('Log Out'),
  ),
),

    );
  }
}

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  static const String routeName = '/addFood';

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields.
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Sample list of categories. Replace or extend as necessary.
  List<Category> _categories = [];
  String? _selectedCategoryId;

  // List of units.
  final List<String> _units = ['g', 'ml', 'kg', 'L', 'no.'];
  String? _selectedUnit;

  String? _userID;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _userID = prefs.getString('userID');

    if (_userID != null) {
      final categories = await CategoryRepository().getAllCategories(int.parse(_userID!));
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id.toString(); // Default to the first category.
        }
        _selectedUnit = _units.first; // Default to the first unit.
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed.
    _foodNameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _addFood() {
    if (_formKey.currentState!.validate()) {

      final foodName = _foodNameController.text.trim();
      final description = _descriptionController.text.trim();
      final quantityText = _quantityController.text.trim();
      final quantity = quantityText.isNotEmpty ? double.tryParse(quantityText) : null;
      final category = _selectedCategoryId;
      final unit = _selectedUnit;
      final createdAt = DateTime.now().toString();
      final updatedAt = DateTime.now().toString();
      final userId = _userID;

      Food newFood = Food(
        name: foodName,
        description: description,
        quantity: quantity,
        unit: unit,
        categoryId: int.parse(category!),
        createdAt: createdAt,
        updatedAt: updatedAt,
        userId: int.parse(userId!),
      );

      FoodRepository().insertFood(newFood);


      // Optionally, clear form or navigate away:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Food name input. Required field.
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Food name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category dropdown.
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id.toString(),
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (newVal) {
                  setState(() {
                    _selectedCategoryId = newVal;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Optional description input.
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Row for quantity input and unit dropdown.
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          _selectedUnit = newVal;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Button to add new food item.
              ElevatedButton(
                onPressed: _addFood,
                child: const Text('Add Food'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, BarcodePage.routeName);
                },
                child: const Text('Have a barcode instead?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarcodePage extends StatelessWidget {
  const BarcodePage({super.key});

  static const String routeName = '/barcode';

  Future<dynamic> fetchData(String barcode) async{
    String URL = "https://world.openfoodfacts.org/api/v3/product/$barcode.json";
    Response responseFromAPI = await http.get(Uri.parse(URL));

    dynamic response = jsonDecode(responseFromAPI.body);

    return response;

  }

  Future<Food> createFood(dynamic response, context) async{
    int loggedInUserId=0;
    final prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    if (userID != null) {
      loggedInUserId = int.parse(userID);}
    
    Food newFood = Food(
      name: response["product"]["product_name"],
      categoryId: 1,
      userId: loggedInUserId,
      imageUrl: response["product"]["selected_images"]["front"]["thumb"]["en"],
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
      description: response["product"]["ingredients_text_en"] ?? 'N/A',
      quantity: response["product"]["serving_quantity"] != null
    ? double.tryParse(response["product"]["serving_quantity"].toString()) ?? 0.0
    : 0.0,
      unit: response["product"]["serving_quantity_unit"] ?? 'N/A',
    );

    FoodRepository().insertFood(newFood);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item added successfully!')),
      );
    return newFood;

  }
  @override
  Widget build(BuildContext context) {
    final TextEditingController _barcodeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Enter Barcode')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Barcode',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final barcode = _barcodeController.text.trim();
                if (barcode.isNotEmpty) {
                  dynamic response = fetchData(barcode);
                  response.then((value) {
                    if (value["result"]["name"]== 'Product found') {
                      createFood(value, context);
                      
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid barcode')),
                      );
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a barcode')),
                  );
                }
              },
              child: const Text('Submit Barcode'),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => BarcodeScannerWidget()),
                );
                if (code != null && code.isNotEmpty) {
                  final response = await fetchData(code);
                  if (response["result"]["name"] == 'Product found') {
                    await createFood(response, context);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid barcode')),
                    );
                  }
                }
              },
              child: Text('Scan Barcode'),
            )

          ],
        ),
      ),
    );
  }
}

class BarcodeScannerWidget extends StatefulWidget {
  @override
  _BarcodeScannerWidgetState createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  late CameraController _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(
  formats: [BarcodeFormat.ean13, BarcodeFormat.upca],
);
  bool _isDetecting = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final camera = await availableCameras().then((cams) => cams.first);
    _cameraController = CameraController(camera, ResolutionPreset.medium);

    try {
      await _cameraController.initialize();
      await _cameraController.startImageStream(_processCameraImage);
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Camera initialization failed: $e");
    }
  }

  void _processCameraImage(CameraImage image) {
    if (_isDetecting) return;
    _isDetecting = true;

    final inputImage = InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );

    _barcodeScanner.processImage(inputImage).then((barcodes) {
  debugPrint("Detected ${barcodes.length} barcodes");
  for (final barcode in barcodes) {
    debugPrint("Barcode value: ${barcode.rawValue}");
  }

  if (barcodes.isNotEmpty && mounted) {
    Navigator.of(context).pop(barcodes.first.rawValue);
  }
}).whenComplete(() => _isDetecting = false);

  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(_cameraController);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }
}
