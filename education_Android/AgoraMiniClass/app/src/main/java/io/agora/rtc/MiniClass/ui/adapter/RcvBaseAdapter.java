package io.agora.rtc.MiniClass.ui.adapter;

import android.support.v7.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public abstract class RcvBaseAdapter<T, VH extends RecyclerView.ViewHolder> extends RecyclerView.Adapter<VH> {
    protected List<T> mList;

    public void addList(List<T> list) {
        if (mList == null)
            mList = list;
        else
            mList.addAll(list);
    }

    public void setList(List<T> list) {
        mList = list;
    }

    public void updateItemById(String id, T item) {
        if (mList == null || id == null) {
            return;
        }
        for (int i = 0; i < mList.size(); i++) {
            if (id.equals(getItemStringId(i))) {
                mList.set(i, item);
                notifyItemChanged(i);
            }
        }
    }

    protected String getItemStringId(int position){
        return null;
    };

    public void addItem(T item) {
        if (item == null)
            return;
        if (mList == null)
            mList = new ArrayList<>();

        mList.add(item);
    }

    @Override
    public int getItemCount() {
        return mList == null ? 0 : mList.size();
    }

    public List<T> getList() {
        return mList;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    public T getItem(int position) {
        return mList.get(position);
    }
}
