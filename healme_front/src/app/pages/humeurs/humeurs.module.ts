import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { HumeursPageRoutingModule } from './humeurs-routing.module';

import { HumeursPage } from './humeurs.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    HumeursPageRoutingModule
  ],
  declarations: [HumeursPage]
})
export class HumeursPageModule {}
