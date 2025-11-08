import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { TherapistListPageRoutingModule } from './therapist-list-routing.module';

import { TherapistListPage } from './therapist-list.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    TherapistListPageRoutingModule
  ],
  declarations: [TherapistListPage]
})
export class TherapistListPageModule {}
