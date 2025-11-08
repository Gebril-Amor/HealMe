import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { HumeursPage } from './humeurs.page';

const routes: Routes = [
  {
    path: '',
    component: HumeursPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class HumeursPageRoutingModule {}
