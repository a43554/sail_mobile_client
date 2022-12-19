
// Show a loading icon.
import 'package:flutter/material.dart';

void showLoadingIcon(BuildContext context) {
	showDialog(
		context: context,
		barrierDismissible: false,
		builder: (BuildContext context) {
			return Dialog(
				backgroundColor: Colors.transparent,
				child: Container(
					color: Colors.transparent,
					alignment: AlignmentDirectional.center,
					child: Container(
						decoration: BoxDecoration(
							color: Colors.transparent,
							borderRadius: BorderRadius.circular(10.0)
						),
						width: 300.0,
						height: 200.0,
						alignment: AlignmentDirectional.center,
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.center,
							mainAxisAlignment: MainAxisAlignment.center,
							children: const <Widget>[
								Center(
									child: SizedBox(
										height: 50.0,
										width: 50.0,
										child: CircularProgressIndicator(
											value: null,
											strokeWidth: 7.0,
											color: Colors.blue,
										),
									),
								),
							],
						),
					),
				),
			);
		},
	);
}

// Display an error.
void showError(BuildContext context, String? errorText) {
	showDialog(
		context: context,
		barrierDismissible: true,
		builder: (BuildContext context) {
			return Dialog(
				backgroundColor: Colors.transparent,
				child: GestureDetector(
					onTap: (){
						// Remove the dialog.
						Navigator.pop(context);
					},
					child: Container(
						color: Colors.transparent,
						alignment: AlignmentDirectional.center,
						child: Wrap(children: [Container(
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(10.0)
							),
							alignment: AlignmentDirectional.center,
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.center,
								mainAxisAlignment: MainAxisAlignment.center,
								children: <Widget>[
									Center(
										child: Container(
											margin: const EdgeInsets.only(
												top: 25.0,
												bottom: 25.0,
												left: 25.0,
												right: 25.0,
											),
											child: Center(
												child: Text(
													(errorText==null) ? "ERRO" : errorText,
													style: const TextStyle(
														color: Colors.blue
													),
												),
											),
										),
									),
								],
							),
						),],),
					),
				),
			);
		},
	);
}