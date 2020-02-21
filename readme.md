# Raw Patient Folder

## Description of contents

This folder contains only raw, unprocessed data from VivaLNK ECG patch. The file sizes after extraction of data will be too large to maintain. Rsync or an alternative method will be used to sync large files into the raw patient folder.

## Patient log

There will also be a file 'patient_log.csv' that helps to identify each patient that is collected. This will remain in the folder and be updated with every new patient added.

# Standardized Operation Protocol

## Intent

This serves as a description of the necessary steps that any Biobank staff member can use to gather the ECG data using the VivaLNK patch.

## Overview of SOP

The general steps are straightforward. The patch is attached to patient at left mid-axillary line at the level of the heart. The blue-tooth enabled phone syncs to the VivaLNK, and sample collection begins. At end of study, the phone application is use to stop sample collection. The data is extracted from the device, and stored. The phone and VivaLNK are stored.

## VivaLNK SDK

For Android, install the SDK through the shared box folder. For Apple/iOS, Tony Ma shared a TestFlight public link for using it.

https://testflight.apple.com/join/HdIrxxu2


## VivaLNK Device Care

The patch itself is washable, and can be easily cleaned with simple sanitizer. The device is reusable. The adhesives are low-cost, and single-use. The device comes with its own charger. It has the battery life of ~72 hours, and can charge to full within ~3 hours.

The charger is a white USB powered device. It will glow _white_ when it is charging, and it will glow _green_ when charging is complete.

The VivaLNK, for data extraction, requires a blue-tooth device for extraction. There is developer app on both Android and iPhone devices to allow connection to the device. The phone and phone charger should be kept with the VivaLNK when not in use.

## Attaching the ECG Patch

1. Charge VivaLNK patch with included charger.
1. Charge phone and enable bluetooth for connectivity with the patch.
1. Consent patient, preferably as close to 7 AM as possible (whether that be in the morning or the night before, per Biobank protocol).
1. Using 3-step adhesive, place VivaLNK patch on patient at left mid-axillary line at the level of the heart (usually 4-7 inches below "armpit").
1. Enable Android/iPhone application "VivaLNK" and connect to device.
1. Enter or ID number through __Set Info__ button.
1. __SetClock__ will reset the timer to ensure synchrony. Write down the time the sampling starts (HH:MM). This will help with file processing.
1. Press __Start Sampling__ to enable data collection to begin. Visualize/check to ensure proper lead placement in the __Graphics__ button (choose RTS option for real-time data).
1. Allow patient to return to scheduled activities. The phone does not need to be near the patient, as the device stores information on its own (up to 24 hours).
1. At end of study, after catherization, approach patient and use device to __Stop Sampling__. If they are outpatient, ideally a few hours of post-cath data would be helpful. If they are inpatient, device can be kept overnight.
1. Remove device from patient. Clean device and throw away adhesives.
1. Charge the VivaLNK and phone until next use.

## Extracting the ECG Data

1. The extraction process is slow, and will require the phone to sync to the VivaLNK patch. Once back in the room, reconnect phone to patch using VivaLNK SDK application. The patch itself has an ID number, which will be seen on the device menu. Make sure it matches when there are multiple devices.
1. The patch will upload data onto the phone for the next several hours. The files should be 2.5 MB for every hour of recording (e.g. 20 hours is ~55 MB). Make sure the phone remains plugged in, and the bluetooth stays connected. The patch can be placed for charging.
1. The file is located on the device under the folder 'VivaLNK/vSDK/c[device #]/data.txt'.
1. Upload this text file, after verifying its size, to the "biobank" box folder under named _raw_patients_.
1. Update the excel file 'patient_log.csv' and include the GENE ID number, the date of collection, and the appropriate time stamps.
1. The time stamps include when patch was activated/turned-on, time of LHC, time of stent deployment, time of balloon angioplasty. If there are other concerns, you may note them here.
1. After the file has been uploaded, go to the phone and delete the text file (to not mix with the next patient's recording). Clear the flash data on the patch through the app interface.

# Folder organization

- __HeartTrends__: RR intervals to be given to HeartTrends, and DYX result files received from HT algorithm.
- __archive__: Old project code or files that may need to be referenced (cannot guarantee path structures).
- __code__: Code files in both R and Matlab.
- __datasets__: Biobank datasets that contain population information, including catherization and clinical history. Exported from REDCap.
- __raw_data__: VivaLNK ECG data log files that have not been processed. Patient overview is also present in XLS file.
- __proc_data__: Matlab converted to HRV files for each patient
- __reference__: Data dictionaries and other reference files. May include literature if needed.
- __team_project__: Biobank study team research project, mainly a lesson in learning how to use R and RStudio. Template files are kept there for their education.

# Miscellaneous

## Contact Information

If there are any questions, please address them to:

Anish Shah, MD
asshah4@emory.edu
469-835-7606

Project Team: Anish Shah, Amit Shah, Alvaro Alonso, Marc Thames, Viola Vaccarino, Arshed Quyyumi
