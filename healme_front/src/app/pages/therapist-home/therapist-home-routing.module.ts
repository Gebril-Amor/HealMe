import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { TherapistHomePage } from './therapist-home.page';

const routes: Routes = [
  {
    path: '',
    component: TherapistHomePage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class TherapistHomePageRoutingModule {}
