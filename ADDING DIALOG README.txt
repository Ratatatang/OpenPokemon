Dialog is probably one of the more confusing parts of the code

Heres a sample dialog file, the one that nurse joy uses

{
    "NextDia":{"Name":  "Nurse Joy", "Text": "hello, and welcome to the pokemon center!", "Portrait": "NurseJoy",
        "NextDia": {"Name":  "Nurse Joy", "Text": "would you like to heal your pokemon?",  "Portrait": "NurseJoyHappy",
            "Decis": {
                "Yes": {"Name":  "Nurse Joy", "Text": "Great, let me  take them for one second", "Portrait": "NurseJoyHappy", "Event": "nurseHeal",
                    "NextDia": {"Name":  "Nurse Joy", "Text": "We hope to serve you again soon!", "Portrait": "NurseJoy"}},
                "No": {"Name":  "Nurse Joy", "Text": "We hope to serve you again soon!",  "Portrait": "NurseJoy"}
            }
        }
    }
}


we'll start with NextDia. that flags the start of any dialog, as well as what the next peice of dialog is. you always have to start your dialog inside one of these

Name is the name that's displayed above the dialog box

Text is the dialog in the box

Portrait is the name of the file that should be displayed. if there is no portrait feild, no portrait will be displayed

Event is the name of any event that needs to be called after that specific peice of dialog

Decis flags the start of a decision. inside of it, you have the choices available to you, and inside of them, the dialog they lead to.

To end dialog, you just need to not put a Decis or NextDia in that dialog.


