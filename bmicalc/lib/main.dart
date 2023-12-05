import 'package:flutter/material.dart';
import 'model/bmicalc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:
        Colors.pink),
        useMaterial3: true,
      ),
      home: BMICalculator(),
    );
  }
}

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}
class _BMICalculatorState extends State<BMICalculator> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();

  double bmi = 0;
  String status = '';
  String? gender;

  int maleCount = 0;
  int femaleCount = 0;

  double maleBmiSum = 0;
  double femaleBmiSum = 0;

  Future<void> displaySavedData() async {
    List<BmiCalc> savedData = await BmiCalc.loadAll();
    if (savedData.isNotEmpty) {
      // Assuming you want to display the last saved item, you can modify this part as needed
      BmiCalc lastSavedItem = savedData.last;
      setState(() {
        usernameController.text = lastSavedItem.username;
        heightController.text = lastSavedItem.height.toString();
        weightController.text = lastSavedItem.weight.toString();
        bmiController.text = lastSavedItem.bmi_status;
        gender = lastSavedItem.gender;
        // Update status when gender changes
        updateStatus();


        // Count and display the total for each gender
        countAndDisplayGenderTotals(savedData);
      });
    }
  }


  void countAndDisplayGenderTotals(List<BmiCalc> savedData) {
    // Reset counts and sums
    maleCount = 0;
    femaleCount = 0;
    maleBmiSum = 0;
    femaleBmiSum = 0;


    // Count records for each gender and calculate sum of BMI
    for (var item in savedData) {
      if (item.gender == 'Male') {
        maleCount++;
        maleBmiSum += double.parse(item.bmi_status);
      } else if (item.gender == 'Female') {
        femaleCount++;
        femaleBmiSum += double.parse(item.bmi_status);
      }
    }
  }


  @override
  void initState() {
    super.initState();
    // Wait for the widgets to be initialized before loading saved data
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      displaySavedData();
    });
  }


  void _calculateBMI() {
    double height = double.parse(heightController.text);
    double weight = double.parse(weightController.text);

    if (height > 0 && weight > 0) {
      bmi = weight! / ((height! / 100) * (height! / 100));

      setState(() {
        bmiController.text = bmi.toStringAsFixed(2);
        updateStatus();
        // Save data when BMI is calculated
        saveData();
        // Display saved data after saving
        displaySavedData();
      });
    }
  }

  void saveData() async {
    // Save to local SQLite
    await BmiCalc(
      usernameController.text,
      double.parse(weightController.text),
      double.parse(heightController.text),
      gender!,
      bmi.toStringAsFixed(2), // Save BMI as a formatted string
    ).save();
  }


  void updateStatus() {
    if (gender == 'Male') {
      if (bmi! < 18.5) {
        status = 'Underweight. Careful during strong wind!';
      } else if (bmi! < 25) {
        status = 'That’s ideal! Please maintain.';
      } else if (bmi! < 30) {
        status = 'Overweight! Work out please.';
      } else {
        status = 'Whoa Obese! Dangerous mate!';
      }
    } else {
      if (bmi! < 16) {
        status = 'Underweight. Careful during strong wind!';
      } else if (bmi! < 22) {
        status = 'That’s ideal! Please maintain.';
      } else if (bmi! < 27) {
        status = 'Overweight! Work out please.';
      } else {
        status = 'Whoa Obese! Dangerous mate!';
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator',
            style: TextStyle(color: Colors.yellowAccent, fontSize: 32)),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Your Fullname',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'Height in cm; eg: 157',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight in KG; eg: 54',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: bmiController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'BMI Value',
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Male',
                        style: TextStyle(color: Colors.blueAccent, fontSize: 20)),
                    leading: Radio(
                      value: 'Male',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value as String?;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Female',
                        style: TextStyle(color: Colors.pinkAccent, fontSize: 20)),
                    leading: Radio(
                      value: 'Female',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value as String?;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Display the status along with the gender
            ElevatedButton(
              onPressed: () {
                _calculateBMI();
              },
              child: Text('Calculate BMI and Save'),
            ),
            Center(
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),


            // Display counts and averages
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row 1: Male Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Count for Male: $maleCount',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),


                  // Row 2: Female Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Count for Female: $femaleCount',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),


                  // Row 3: Average for Male BMI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Average for Male BMI: ${maleCount > 0 ? (maleBmiSum /
                            maleCount).toStringAsFixed(2) : 'N/A'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),


                  // Row 4: Average for Female BMI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Average for Female BMI: ${femaleCount > 0 ? (femaleBmiSum /
                            femaleCount).toStringAsFixed(2) : 'N/A'}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
