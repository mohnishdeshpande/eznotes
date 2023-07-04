import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() {
  // LEARN MORE ABOUT THIS
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'My Notes',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
    },
  ));
}

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = AuthService.firebase();

//     return FutureBuilder(
//       // initialise firebase before building/redering the column
//       future: authService.initialise(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             // get current user
//             final user = authService.currentUser;
//             // if user is logged in
//             if (user != null) {
//               if (user.emailVerified) {
//                 // if email is verified load Notes
//                 return const NotesView();
//               } else {
//                 // load verif email
//                 return const VerifyEmailView();
//               }
//             } else {
//               // load login if not logged in
//               return const LoginView();
//             }
//           default:
//             return const CircularProgressIndicator();
//         }
//       },
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing Bloc'),
          backgroundColor: Colors.blue,
        ),
        // using Consumer since listener and builder both are involved
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue = (state is CounterStateInvalid) ? state.invalidValue : '';
            return Column(
              children: [
                Text('Current Value: ${state.value}'),
                Visibility(
                  child: Text('Invalid input: $invalidValue'),
                  visible: state is CounterStateInvalid,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Enter a number here'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(DecrementEvent(_controller.text));
                      },
                      child: const Text('-'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(IncrementEvent(_controller.text));
                      },
                      child: const Text('+'),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(super.value);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue;
  const CounterStateInvalid({
    required this.invalidValue,
    required int prevValue,
  }) : super(prevValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(super.value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(super.value);
}

// read deal
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(CounterStateInvalid(
            invalidValue: event.value,
            prevValue: state.value,
          ));
        } else {
          emit(CounterStateValid(state.value + integer));
        }
      },
    );

    on<DecrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.value);
        if (integer == null) {
          emit(CounterStateInvalid(
            invalidValue: event.value,
            prevValue: state.value,
          ));
        } else {
          emit(CounterStateValid(state.value - integer));
        }
      },
    );
  }
}
