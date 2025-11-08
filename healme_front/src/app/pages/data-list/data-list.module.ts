import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { DataListPageRoutingModule } from './data-list-routing.module';

import { DataListPage } from './data-list.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    DataListPageRoutingModule
  ],
  declarations: [DataListPage]
})
export class DataListPageModule {}
