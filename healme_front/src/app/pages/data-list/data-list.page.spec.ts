import { ComponentFixture, TestBed } from '@angular/core/testing';
import { DataListPage } from './data-list.page';

describe('DataListPage', () => {
  let component: DataListPage;
  let fixture: ComponentFixture<DataListPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(DataListPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
