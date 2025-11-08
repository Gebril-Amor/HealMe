import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AddDataPage } from './add-data.page';

describe('AddDataPage', () => {
  let component: AddDataPage;
  let fixture: ComponentFixture<AddDataPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(AddDataPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
