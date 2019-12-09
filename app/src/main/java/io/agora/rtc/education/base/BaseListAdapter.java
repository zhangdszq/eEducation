package io.agora.rtc.education.base;

import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

public abstract class BaseListAdapter<T> extends BaseAdapter {
    private List<T> mList = new ArrayList<>();

    public List<T> getList() {
        return mList;
    }

    public void setList(@NonNull List<T> mList) {
        this.mList = mList;
    }

    public void addItem(T item) {
        this.mList.add(item);
    }

    @Override
    public int getCount() {
        return mList.size();
    }

    @Override
    public Object getItem(int position) {
        return mList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        BaseViewHolder viewHolder;
        if (convertView == null) {
            viewHolder = onCreateViewHolder(getItemViewType(position), parent);
            convertView = viewHolder.itemView;
            convertView.setTag(viewHolder);
        } else {
            viewHolder = (BaseViewHolder) convertView.getTag();
        }
        onBindViewHolder(viewHolder, mList.get(position), position);
        return convertView;
    }

    protected abstract void onBindViewHolder(BaseViewHolder viewHolder, T t, int position);

    protected abstract BaseViewHolder onCreateViewHolder(int itemViewType, ViewGroup parent);

    public static class BaseViewHolder{
        public View itemView;

        public BaseViewHolder(View itemView) {
            this.itemView = itemView;
        }
    }
}
