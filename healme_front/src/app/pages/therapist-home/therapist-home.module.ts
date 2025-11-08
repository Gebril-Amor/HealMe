import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { TherapistHomePageRoutingModule } from './therapist-home-routing.module';

import { TherapistHomePage } from './therapist-home.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    TherapistHomePageRoutingModule
  ],
  declarations: [TherapistHomePage]
})
export class TherapistHomePageModule {}
