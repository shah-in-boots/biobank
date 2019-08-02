# Raw Patient Folder

## Description of contents

This folder contains only raw, unprocessed data from VivaLNK ECG patch. The file sizes after extraction of data will be too large to maintain. 

## Patient log

There will also be a file 'patient_log.csv' that helps to identify each patient that is collected. This will remain in the folder and be updated with every new patient added.

# Standardized Operation Protocol

## Intent

This serves as a description of the necessary steps that any Biobank staff member can use to gather the ECG data using the VivaLNK patch.

## Overview of SOP

The general steps are straightforward. The patch is attached to patient at left mid-axillary line at the level of the heart. The blue-tooth enabled phone syncs to the VivaLNK, and sample collection begins. At end of study, the phone application is use to stop sample collection. The data is extracted from teh device, and stored. The phone and VivaLNK are stored.

## VivaLNK Device Care

The patch itself is washable, and can be easily cleaned with simple sanitizer. The device is reusable. The adhesives are low-cost, and single-use. The device comes with its own charger. It has the battery life of ~72 hours, and can charge to full within ~3 hours. 

The charger is a white USB powered device. It will glow _white_ when it is charging, and it will glow _green_ when charging is complete.

The VivaLNK, for data extraction, requires a blue-tooth device for extraction. There is developer app on both Android and iPhone devices to allow connection to the device. The phone and phone charger should be kept with the VivaLNK when not in use. 

## Detailed WorkFlow

1. Charge VivaLNK patch with included charger.
2. Charge phone and enable bluetooth for connectivity with the patch.
3. Consent patient, preferably as close to 7 AM as possible (whether that be in the morning or the night before, per Biobank protocol).
4. Using 3-step adhesive, place VivaLNK patch on patient at left mid-axillary line at the level of the heart (usually 4-7 inches below "armpit").
5. Enable Android/iPhone application "VivaLNK" and sync to device. 
6. Enter patient name or ID number through __Set Info__ button. 
7. __SetClock__ will reset the timer to ensure synchrony. Write down the time the sampling starts (YYYY:MM:DD H:M:S). This will help with file processing.
8. Press __Start Sampling__ to enable data collection to begin. Visualize/check to ensure proper lead placement in the __Graphics__ button (choose RTS option for real-time data).
9. Allow patient to return to scheduled activities. The phone does not need to be near the patient, as the device stores information on its own (up to 24 hours). 
10. At end of study, preferably after catherization, approach patient and use device to __Stop Sampling__. _Collect the start and end time of catherization. If a stent was placed, please attempt to find what time._
11. Remove device from patient. Clean device and throw away adhesives.
12. Plug in phone to save/download the data file. It is located under 'VivaLNK/vSDK/c000/data.txt'. That text file is the data to be extracted.
13. Place this in the shared Box folder called RAW_PATIENTS. 
14. Update the excel file 'patient_log.csv' and include the patient ID, and time stamps collected above.
15. Charge the VivaLNK and phone until next use.
